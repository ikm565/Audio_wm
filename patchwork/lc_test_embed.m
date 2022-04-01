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

audio_files = dir('/public/liuchang/data/fma_wav/testset/*.wav');
audio_filenames = {audio_files.name};

audio_root = '/public/liuchang/data/fma_wav/testset/';
out_root = './results/test/audio/original/';
spectrum_root = './results/test/spectrum/';

snr_list = ones(221,1);
avg_snr = 0;
audio_count = 220;
for i=1:audio_count
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};
    % audio_filenames(i){1,1} = strcat('c1', audio_filenames(i){1,1});
    out_file = strcat(out_root, audio_filenames(i));
    out_file = out_file{1,1};
    spectrum_file = strcat(spectrum_root, audio_filenames(i));
    % now_lambda = the_lambda(i,1);
    [snr, N, M, G,Q_F_W,Q_feature] = rfdlm_embed(500000,audio_file, out_file, bw, delta);
    snr_list(i)=snr;
    avg_snr = avg_snr+snr;
end
snr_list(audio_count+1)=avg_snr/audio_count;
save ('./results/test/snr_results.mat', 'snr_list');
