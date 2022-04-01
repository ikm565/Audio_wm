'''
Author: Chang Liu
Date: 2022-03-30 22:53:33
LastEditors: Chang Liu
LastEditTime: 2022-03-31 17:24:29
FilePath: /patchwork/utils/traditional_attack.py
Description: do taditional attack to embeded audio

Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
'''
import os
import fire
import torch
import torchaudio
import random
import julius
from hparameters import *
import torch.nn as nn
from impulse_layer import impulse_attack2


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
class attack_opeartion(nn.Module):
    def __init__(self):
        super().__init__()
        self.impulse_layer = impulse_attack2(sr1=10000, sr2=SAMPLE_RATE)
        self.bandpass = julius.BandPassFilter(1/44.1, 4/44.1).to(device)
        self.lowpass = julius.LowPassFilter(7.35/44.1).to(device)
        K = 0.9 
        self.resample1 = julius.ResampleFrac(SAMPLE_RATE, int(SAMPLE_RATE*K)).to(device)
        self.resample2 = julius.ResampleFrac(int(SAMPLE_RATE*K), SAMPLE_RATE).to(device)

        self.band_lowpass = julius.LowPassFilter(4/44.1).to(device)
        self.band_highpass = julius.HighPassFilter(1/44.1).to(device)


    def one_white_noise(self, y): # SNR = 10log(ps/pn)
        choice = [5, 10, 20, 50]
        SNR = random.choice(choice)
        # SNR = 5
        mean = 0.
        RMS_s = torch.sqrt(torch.mean(y**2, dim=2))  # RMS value of signal
        RMS_n = torch.sqrt(RMS_s**2/(pow(10, SNR/20)))  # RMS values of noise
        # Therefore mean=0, to round you can use RMS as STD
        for i in range(y.shape[0]):
            noise = torch.normal(mean, float(RMS_n[i][0]), size=(1, y.shape[2]))
            if i == 0:
                batch_noise = noise
            else:
                batch_noise = torch.cat((batch_noise, noise), dim=0)
        batch_noise = batch_noise.unsqueeze(1).to(device)
        signal_edit = y + batch_noise
        return signal_edit

    def two_band_pass(self, y):
        # y = torchaudio.functional.highpass_biquad(waveform=y, sample_rate=SAMPLE_RATE, cutoff_freq=14700, Q=0.707) # high pass
        # y = torchaudio.functional.lowpass_biquad(waveform=y, sample_rate=SAMPLE_RATE, cutoff_freq=7350, Q=0.707) # low pass
        y = self.lowpass(y)
        # torchaudio.functional.dither（波形： torch.Tensor，密度函数： str = 'TPDF'，noise_shaping ： bool = False） 抖动
        return y

    def three_resample(self, y):
        K = 0.9         
        # y = torchaudio.functional.resample(waveform=y, orig_freq=SAMPLE_RATE, new_freq=SAMPLE_RATE*K, lowpass_filter_width = 6, rolloff=0.99, resampling_method= 'sinc_interpolation', beta=None)
        # y = torchaudio.functional.resample(waveform=y, orig_freq=SAMPLE_RATE*K, new_freq=SAMPLE_RATE, lowpass_filter_width = 6, rolloff=0.99, resampling_method= 'sinc_interpolation', beta=None)
        y = self.resample1(y)
        y = self.resample2(y)
        y = y[:,:,:NUMBER_SAMPLE]
        return y

    def four_new(self, y):
        return y

    def five_mp3(self, y):
        return y

    def six_crop_out(self, y):
        drop_index = torch.ones(y.shape[2], device=device)
        i = 0
        while i < drop_index.shape[0]:
            drop_index[i] = 0.
            i += 100
        return y*drop_index

    def seven_change_top(self, y):
        y = y*0.9
        return y

    def eight_recount(self, y):
        # 左界不会溢出2^16，右界32->16：左移位16，取整，再右移位
        y = torch.round(y*(2**8))/(2**8)
        return y

    def nine_medfilt(self, y):
        return y
    
    def ten_replay(self, y):
        # https://github.com/adefossez/julius
        # Impulse Response
        y = self.impulse_layer.impulse(y)
        #band_pass: 1000-4000HZ
        # y = torchaudio.functional.lowpass_biquad(waveform=y, sample_rate=SAMPLE_RATE, cutoff_freq=4000, Q=0.707) # low pass
        # y = torchaudio.functional.highpass_biquad(waveform=y, sample_rate=SAMPLE_RATE, cutoff_freq=1000, Q=0.707) # high pass
        y = self.bandpass(y)
        # y = self.band_lowpass(self.band_highpass(y))

        #white noise addition
        choice = [40, 50]
        SNR = random.choice(choice)
        mean = 0.
        RMS_s = torch.sqrt(torch.mean(y**2, dim=2))  # RMS value of signal
        RMS_n = torch.sqrt(RMS_s**2/(pow(10, SNR/20)))  # RMS values of noise
        # Therefore mean=0, to round you can use RMS as STD
        for i in range(y.shape[0]):
            noise = torch.normal(mean, float(RMS_n[i][0]), size=(1, y.shape[2]))
            if i == 0:
                batch_noise = noise
            else:
                batch_noise = torch.cat((batch_noise, noise), dim=0)
        batch_noise = batch_noise.unsqueeze(1).to(device)
        y = y + batch_noise

        #sample shift
        # shift_len_left = random.randint(0,SAMPLE_RATE*2)
        # shift_len_right = random.randint(0,SAMPLE_RATE*2)
        # shift_nosie_left = torch.normal(mean, float(RMS_n[0][0]), size=(y.shape[0], y.shape(1), shift_len_left))
        # shift_nosie_left = torch.normal(mean, float(RMS_n[0][0]), size=(y.shape[0], y.shape(1), shift_len_right))
        # y = torch.cat([shift_len_left, y, shift_len_right], dim=2)

        return y

    def attack(self, y, choice=None):
        '''
        y:[batch, 1, audio_length]
        out:[batch, 1, audio_length]
        '''
        if choice == None:
            return y
        elif choice == 1:
            return self.one_white_noise(y)
        elif choice == 2:
            return self.two_band_pass(y)
        elif choice == 3:
            return self.three_resample(y)
        elif choice == 4:
            return self.four_new(y)
        elif choice == 5:
            return self.five_mp3(y)
        elif choice == 6:
            return self.six_crop_out(y)
        elif choice == 7:
            return self.seven_change_top(y)
        elif choice == 8:
            return self.eight_recount(y)
        elif choice == 9:
            return self.nine_medfilt(y)
        elif choice == 10:
            return self.ten_replay(y)
        elif choice== 12:
            y = self.one_white_noise(y)
            y = self.two_band_pass(y)
            y = self.three_resample(y)
            y = self.six_crop_out(y)
            y = self.seven_change_top(y)
            y = self.eight_recount(y)
            return y
        elif choice==11:
            ch = [1,2,3,6,7,8]
            ch2 = random.choice(ch)
            y = self.attack(y,choice=ch2)
            return y
        else:
            return y

def main(attack_choice="1", original="../results/test/audio/original/"):
    """_summary_

    Args:
        original (str, optional): original audio path:embed audio. Defaults to "../results/audio/original/".
        attacked (str, optional): attacked audio path:attacked audio. Defaults to "./traditional_attack/1".
        if choice == None:
            return y
        elif choice == 1:
            return self.one_white_noise(y)
        elif choice == 2:
            return self.two_band_pass(y)
        elif choice == 3:
            return self.three_resample(y)
        elif choice == 4:
            return self.four_new(y)
        elif choice == 5:
            return self.five_mp3(y)
        elif choice == 6:
            return self.six_crop_out(y)
        elif choice == 7:
            return self.seven_change_top(y)
        elif choice == 8:
            return self.eight_recount(y)
        elif choice == 9:
            return self.nine_medfilt(y)
        elif choice == 10:
            return self.ten_replay(y)
        elif choice== 12:
            y = self.one_white_noise(y)
            y = self.two_band_pass(y)
            y = self.three_resample(y)
            y = self.six_crop_out(y)
            y = self.seven_change_top(y)
            y = self.eight_recount(y)
            return y
        elif choice==11:
            ch = [1,2,3,6,7,8]
            ch2 = random.choice(ch)
            y = self.attack(y,choice=ch2)
            return y
        else:
            return y
    Returns:
        _type_: _description_
    """
    print(f"{type(original)}\t{type(attack_choice)}")
    attack_choice = str(attack_choice)
    original = str(original)
    
    attacker = attack_opeartion()
    #---------------------------get AUDIO--------------------------
    root = original
    files = os.listdir(root)
    files.sort()
    audio_list = []
    for file_ in files:
        if file_[-4:] == ".wav":
            audio_list.append(file_)
    
    #---------------------------DO ATTACK--------------------------
    attack_path = os.path.join("../results/test/audio/traditional_attack/", attack_choice)
    if not os.path.exists(attack_path):
        os.makedirs(attack_path)
    print(attack_path)
    for SELECT_AUDIO_NAME in audio_list:
        audio, sr = torchaudio.load(os.path.join(root, SELECT_AUDIO_NAME))
        audio = audio.to(device)
        attack_audio = attacker.attack(audio.unsqueeze(0), int(attack_choice))
        out_audio_path = os.path.join(attack_path, SELECT_AUDIO_NAME)
        
        torchaudio.save(out_audio_path, attack_audio.squeeze(0).cpu(), sr)
        # logging.info("\nattacked audio:{}".format(out_audio_path))
    #---------------------------save ATTACKED--------------------------
    return 0


if __name__ == "__main__":
    import fire
    fire.Fire(main)
