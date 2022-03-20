clc;
clear;
inp = 'E:\worksapce\python_worksapce\matlab_audio_watermark\Audio-Watermarking-master\jazz.wav';
oup = 'E:\worksapce\python_worksapce\matlab_audio_watermark\output22.wav';
img = 'E:\worksapce\python_worksapce\matlab_audio_watermark\eg.jpg';
img_output = 'E:\worksapce\python_worksapce\matlab_audio_watermark\out_eg.jpg';
lambda = 0.28;
attacked='E:\worksapce\python_worksapce\matlab_audio_watermark\attacked.wav';
audio_root = 'E:\worksapce\python_worksapce\watermark-gan\Steganography_GANs\dataset\music_dataset\16000\val\val_resample\';
image_root = 'E:\worksapce\python_worksapce\matlab_audio_watermark\image\';
audio_files = dir('E:\worksapce\python_worksapce\watermark-gan\Steganography_GANs\dataset\music_dataset\16000\val\val_resample\*.wav');
audio_filenames = {audio_files.name};
% r=randperm( size(audio_filenames,2) );
% audio_filenames = audio_filenames(:, r);
image_files = dir('E:\worksapce\python_worksapce\matlab_audio_watermark\image\*.jpg');
image_filenames = {image_files.name};

load('the_lambda.mat');
i=8;
audio_file = strcat(audio_root, audio_filenames(i));
audio_file = audio_file{1,1}
image_file = strcat(image_root, image_filenames(i));
image_file = image_file{1,1};
now_lambda = the_lambda(i,1)
snr = embed(audio_file,oup,img,now_lambda)
[status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack6.py');
acc = extract(attacked,audio_file,img,img_output,now_lambda)
    

