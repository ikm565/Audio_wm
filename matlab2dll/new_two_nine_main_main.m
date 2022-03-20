clc;
clear;
inp = 'E:\worksapce\python_worksapce\matlab_audio_watermark\Audio-Watermarking-master\jazz.wav';
oup = 'E:\worksapce\python_worksapce\matlab_audio_watermark\output22.wav';
img = 'E:\worksapce\python_worksapce\matlab_audio_watermark\eg.jpg';
img_output = 'E:\worksapce\python_worksapce\matlab_audio_watermark\out_eg.jpg';
lambda = 0.28;
%obj(2) = PQevalAudio(inp,oup);
 %tic;
%obj = compute(inp,img,lambda);

% snr = embed(inp,oup,img,lambda)
attacked='E:\worksapce\python_worksapce\matlab_audio_watermark\attacked.wav';
% acc_val = extract(oup,inp,img,img_output,lambda);
%extract(oup,inp,img,img_out,lambda);
%disp(num2str(toc));

% mh = rand(1,13622);
% tic;
% mh = single(mh);
% 
% [U,S,V] = svd(mh);
% disp(num2str(toc));











audio_root = 'E:\worksapce\python_worksapce\watermark-gan\FMA_dataset\test\test\';
image_root = 'E:\worksapce\python_worksapce\matlab_audio_watermark\image\';
audio_files = dir('E:\worksapce\python_worksapce\watermark-gan\FMA_dataset\test\test\*.wav');
audio_filenames = {audio_files.name};
embed_audio_root = 'E:\worksapce\python_worksapce\watermark-gan\FMA_dataset\test\embed\';


image_files = dir('E:\worksapce\python_worksapce\matlab_audio_watermark\image\*.jpg');
image_filenames = {image_files.name};
avg_snr = 0;
snr_list = zeros(10,1);
load('two_nine_lambda.mat');
for i=1:10
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};
    image_file = strcat(image_root, image_filenames(i));
    image_file = image_file{1,1};
    now_lambda = change_lambda(i,1);
    oup = strcat(embed_audio_root, audio_filenames(i));
    oup = oup{1,1};
    snr = embed(audio_file,oup,image_file,now_lambda);
    snr_list(i) = snr;
    avg_snr = avg_snr + snr;
end

avg_snr = avg_snr/10

save('two_nine_snr_list.mat','snr_list');

    

