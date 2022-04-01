from pydub import AudioSegment
import cv2
import copy
import skimage
import librosa
import numpy as np
import torch
import torchaudio
import soundfile
import math
import pywt
from scipy.signal import medfilt

#加噪
def add_noise(data):
    wn = np.random.normal(0,1,len(data))
    data_noise = np.where(data != 0.0, data.astype('float64') + 0.02 * wn, 0.0).astype(np.float32)
    return data_noise


def add_white_noise(signalData, samplingFrequency):#Additive white gausian noise.
    #SNR -> Signal to Noise Ratio
    choice = [5,10,20, 50]
    #SNR = random.choice(choice)
    SNR=20
    #samplingFrequency, signalData = wavfile.read(file_path)
    RMS_s=math.sqrt(np.mean(signalData**2))#RMS value of signal
    RMS_n=math.sqrt(RMS_s**2/(pow(10,SNR/20)))#RMS values of noise
    #Therefore mean=0, to round you can use RMS as STD
    np.random.seed(2021)
    noise=np.random.normal(0, RMS_n, signalData.shape[0])
    signal_edit = signalData + noise
    return signal_edit


from scipy.signal import butter, lfilter
def butter_bandpass(lowcut, highcut, fs, order=5): #巴特沃斯带通滤波器
    nyq = 0.5 * fs #Nyquist frequence
    if lowcut is None:
        high = float(highcut / nyq)
        b, a = butter(order, high, btype='low')
    elif highcut is None:
        low = float(lowcut / nyq)
        b, a = butter(order, low, btype='high')
    else:
        low = float(lowcut / nyq)
        high = float(highcut / nyq)
        b, a = butter(order, [low, high], btype='band')
    return b, a


def bandpass_filter(signalData, samplingFrequency):
    #samplingFrequency, signalData = wavfile.read(file_path)
    FILTERS ={
    "LP" : butter_bandpass(None, 7350.0, 44100.0, order=5),
    "MP" : butter_bandpass(7350.0, 14700.0, 44100.0, order=5),
    "HP" : butter_bandpass(14700.0, None, 44100.0, order=5)
    }
    #choice = ["LP","MP","HP"]
    #choice = ["LP"]
    b, a = FILTERS["LP"]
    y = lfilter(b, a, signalData)
    return y

def resample(aud,sr):
    k = 0.9
    #zeros_father = len(aud)
    aud = librosa.resample(aud,sr,sr*k)
    aud = librosa.resample(aud,sr*k,sr)
    #zeros_count = zeros_father-len(aud)
    #aud = np.hstack((aud,np.zeros(zeros_count)))
    return aud
    
def new_attack(aud,sr):
    y = aud
    # 读取音频
    ly = len(y) 
    y_tune = cv2.resize(y, (1, int(len(y) * 1.2))).squeeze() 
    lc = len(y_tune) - ly 
    y_tune = y_tune[int(lc / 2):int(lc / 2) + ly]
    return y_tune

def mp3(aud,sr):
    wav_path = "../xxx_tune.wav"
    path = "../xxx_tune.mp3"
    #librosa.output.write_wav(wav_path, aud, sr,norm=False)
    soundfile.write(wav_path, aud, samplerate=sr)
    song = AudioSegment.from_wav(wav_path).set_frame_rate(sr)
    song.export(path, format='mp3', bitrate='128k')
    aud = AudioSegment.from_mp3(path).set_frame_rate(sr)
    aud.export(wav_path, format='wav')
    aud, sr = torchaudio.load(wav_path)
    aud = aud[0].numpy()
    return aud

def crop(aud,sr):
    for i in range(len(aud)):
        if i%100==0:
            aud[i] = 0
    return aud

def change_top(aud,sr):
    aud = aud*0.9
    return aud

def recount(aud,sr):
    aud = np.float16(aud)
    aud = np.float32(aud)
    return aud

def attack(attack_choice=None):
    before_attack_path = 'E:/worksapce/python_worksapce/matlab_audio_watermark/output22.wav';
    after_attack_path = 'E:/worksapce/python_worksapce/matlab_audio_watermark/attacked.wav';
    sample, sr = torchaudio.load(before_attack_path)
    aud = np.asarray(sample[0])
    
    if attack_choice is None:
        attack_choice = random.randint(0,2)
    #print('attack type: %d' %attack_choice)
    if attack_choice==0:
        #wav = add_noise(aud)
        wav = aud
    elif attack_choice==1:
        wav = add_white_noise(aud, sr)
    elif attack_choice==2:
        wav = bandpass_filter(aud, sr)
    elif attack_choice==3:
        wav = resample(aud, sr)
    elif attack_choice==4:
        wav = new_attack(aud, sr)
    elif attack_choice==5:
        wav = mp3(aud, sr)
    elif attack_choice==6:
        wav = crop(aud, sr)
    elif attack_choice==7:
        wav = change_top(aud, sr)
    elif attack_choice==8:
        wav = recount(aud, sr)
    elif attack_choice==9:
        wav = medfilt(aud, 3)
    else:
        wav = aud
    soundfile.write(after_attack_path, wav, samplerate=sr)
    
if __name__ == "__main__":
    attack(7)