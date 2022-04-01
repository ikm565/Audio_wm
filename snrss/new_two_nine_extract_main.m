% /*
%  * @Author: Chang Liu
%  * @Date: 2022-03-30 21:40:37
%  * @LastEditors: Chang Liu
%  * @LastEditTime: 2022-03-30 21:40:41
%  * @FilePath: /snrss/new_two_nine_extract_main.m
%  * @Description: 
%  * 
%  * Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
%  */

clc;
clear;
inp = 'E:/worksapce/python_worksapce/matlab_audio_watermark/Audio-Watermarking-master/jazz.wav';
oup = 'E:/worksapce/python_worksapce/matlab_audio_watermark/output22.wav';
img = 'E:/worksapce/python_worksapce/matlab_audio_watermark/eg.jpg';
img_output = 'E:/worksapce/python_worksapce/matlab_audio_watermark/out_eg.jpg';
lambda = 0.28;


/public/liuchang/









audio_root = '/public/liuchang/data/fma/test/test/';
image_root = 'E:/worksapce/python_worksapce/matlab_audio_watermark/image/';
audio_files = dir('/public/liuchang/data/fma/test/test/*.wav');
audio_filenames = {audio_files.name};
embed_audio_root = '/public/liuchang/data/fma/test/embed/';
attacked_root='/public/liuchang/data/fma/test/attacked/';
attacked_files = dir('/public/liuchang/data/fma/test/attacked/*.wav');
attacked_filenames = {attacked_files.name};
image_file = "";
avg_acc = zeros(10,1);
acc_list = zeros(10,1);
load('two_nine_lambda.mat');
for i=1:10
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};
    attacked = strcat(attacked_root, attacked_filenames(i));
    attacked = attacked{1,1};
    now_lambda = change_lambda(i,1);
    % fprintf("the audio is %s \n", attacked);
    acc = attacked_extract(attacked,audio_file,image_file,img_output,now_lambda);
    % acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    acc_list(i) = acc;
    avg_acc(10) = avg_acc(10) + acc;
end

avg_acc = avg_acc/10;

save('two_nine_acc_list.mat','acc_list');


