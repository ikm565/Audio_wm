'''
Author: Chang Liu
Date: 2022-03-31 17:43:49
LastEditors: Chang Liu
LastEditTime: 2022-03-31 18:33:26
FilePath: /patchwork/utils/shuffle_result.py
Description: calculate the acc and snr for myself

Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
'''
import scipy.io as sio
import os
import fire

def find_audio_name():
    """find the audio 
    """
    audio_name = ['137149.wav',
                '137422.wav',
                '143047.wav',
                '129497.wav',
                '129500.wav',
                '144723.wav',
                '130372.wav',
                '137423.wav',
                '143042.wav',
                '143532.wav',
                '143186.wav',
                '135221.wav',
                '136134.wav',
                '137586.wav',
                '130882.wav',
                '130909.wav',
                '136547.wav',
                '143048.wav',
                '128824.wav',
                '143043.wav']
    snr_data = sio.loadmat('../results/test/snr_results.mat') # 读入 mat 文件
    audio_fiiles_data = sio.loadmat('../results/test/audio_filenames.mat') # 读入 mat 文件
    snr_list = snr_data['snr_list']
    audio_name_list = audio_fiiles_data['audio_filenames']
    return audio_name, snr_list, audio_name_list


def calculate(attack_type='re-record', attack_choice='5'):
    """calculate snr and attacked acc

    Args:
        attack_choice (str): traditional attack_choice
        attack_type (str, optional): _description_. Defaults to 're-record'.
    """
    avg_acc = 0
    avg_snr = 0
    cut_name, snr_list, audio_name_list = find_audio_name()
    if attack_type == 're-record':
        distance = attack_choice
        acc_list = sio.loadmat(os.path.join("../results/test/audio/re_record",distance+'_acc.mat')) 
        acc_list = acc_list['acc_list']
        for i in range(len(audio_name_list)):
            if audio_name_list[i] in cut_name:
                pass
            else:
                avg_acc += acc_list[i]
                avg_snr += snr_list[i]
        count = 220-len(cut_name)
        avg_acc = avg_acc/count
        avg_snr = avg_snr/count
        out_file = open(os.path.join("../results/test/audio/re_record",'calculate.txt'),'a+')
        out_file.write(f"re-record\t{distance}\tsnr:{avg_snr}\tacc:{avg_acc}\n")
        out_file.close()
    
    else:
        acc_list = sio.loadmat(os.path.join("../results/test/audio/traditional",attack_choice+'_acc.mat')) 
        acc_list = acc_list['acc_list']
        for i in range(len(audio_name_list)):
            if audio_name_list[i] in cut_name:
                pass
            else:
                avg_acc += acc_list[i]
                avg_snr += snr_list[i]
        count = 220-len(cut_name)
        avg_acc = avg_acc/count
        avg_snr = avg_snr/count
        out_file = open(os.path.join("../results/test/audio/traditional",'calculate.txt'),'a+')
        out_file.write(f"re-record\t{distance}\tsnr:{avg_snr}\tacc:{avg_acc}\n")
        out_file.close()
        
if __name__ == "__main__":
    fire.Fire(calculate)    
