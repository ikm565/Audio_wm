%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
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

distance = '20'; %5, 20, 50

audio_root = './results/test/audio/re_record/';
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
    [acc] = auto_extract(500000,audio_file, bw, delta,Q_F_W,Q_feature);
    acc_list(i)=acc;
    avg_acc = avg_acc+acc;
end
acc_list(audio_count+1)=avg_snr/audio_count;
acc_path = strcat('./results/test/audio/re_record/',distance,'_acc.mat')
save (acc_path, 'acc_list');
