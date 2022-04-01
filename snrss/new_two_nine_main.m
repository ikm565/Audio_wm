clc;
clear;
inp = 'E:\worksapce\python_worksapce\matlab_audio_watermark\Audio-Watermarking-master\jazz.wav';
oup = 'E:\worksapce\python_worksapce\matlab_audio_watermark\output22.wav';
img = 'E:\worksapce\python_worksapce\matlab_audio_watermark\eg.jpg';
img_output = 'E:\worksapce\python_worksapce\matlab_audio_watermark\out_eg.jpg';
attacked='E:\worksapce\python_worksapce\matlab_audio_watermark\attacked.wav';


% this is what you need
audio_root = '../../data/fma/test/test/';
image_root = 'E:\worksapce\python_worksapce\matlab_audio_watermark\image\';
audio_files = dir("../../data/fma/test/test/*.wav");
audio_filenames = {audio_files.name};
image_files = dir('E:\worksapce\python_worksapce\matlab_audio_watermark\image\*.jpg');
image_filenames = {image_files.name};
avg_snr = 0;
avg_acc = 0;
change_lambda = zeros(10,1);
%load('the_lambda.mat');
for i=1:10
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};
    image_file = strcat(image_root, image_filenames(i));
    image_file = image_file{1,1};
    % now_lambda = the_lambda(i,1);
    now_lambda = lc_get_lambda(audio_file,oup,image_file,attacked,img_output)
    change_lambda(i) = now_lambda;
end
save ('two_nine_lambda.mat', 'change_lambda');

    

