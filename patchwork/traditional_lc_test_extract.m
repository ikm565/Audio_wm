% /*
%  * @Author: Chang Liu
%  * @Date: 2022-03-30 22:37:02
%  * @LastEditors: Chang Liu
%  * @LastEditTime: 2022-03-30 22:37:05
%  * @FilePath: /patchwork/traditional_lc_test_extract.m
%  * @Description: 
%  * 
%  * Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
%  */

clc;
clear;
bw = [0, 1, 1, 1, 0, 1, 0, 0, 0, 1;...
        1, 0, 1, 0, 0, 0, 0, 1, 1, 0;...
        0, 1, 0, 1, 0, 0, 1, 0, 0, 0;...
        0, 0, 0, 1, 1, 1, 0, 1, 1, 1;...
        0, 1, 1, 0, 1, 1, 0, 1, 0, 0;...
        1, 0, 0, 0, 0, 1, 1, 0, 0, 0;...
        1, 1, 0, 1, 1, 1, 1, 0, 1, 1;...
        0, 1, 1, 0, 0, 0, 1, 1, 0, 1;...
        1, 1, 0, 1, 1, 0, 0, 0, 0, 0;...
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
bw = reshape(bw,10*10,[]);
bw = bw(1:60);
delta = 0.8;

attack_choice = '1';

audio_root = './results/test/audio/traditional_attack/';
audio_root = strcat(audio_root, distance, '/');

audio_files_root = strcat(audio_root,'*.wav')
audio_files = dir(audio_files_root);
audio_filenames = {audio_files.name};

acc_list = ones(221,1);
avg_acc = 0;
audio_count = 220;
for i=1:audio_count
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};

    Q_F_W = 1;
    Q_feature = 1;
    [acc] = traditional_extract(500000,audio_file, bw, delta,Q_F_W,Q_feature);
    acc_list(i)=acc;
    avg_acc = avg_acc+acc;
end
acc_list(audio_count+1)=avg_snr/audio_count;

save_mat_path = strcat('./results/test/audio/traditional_attack/acc_',attack_choice,'.mat')
save (save_mat_path, 'acc_list');
