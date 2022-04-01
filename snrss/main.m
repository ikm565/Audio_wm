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











audio_root = 'D:\workspace\python Workspace\watermark-gan\Steganography_GANs\dataset\music_dataset\16000\val\val_resample\';
image_root = 'E:\worksapce\python_worksapce\matlab_audio_watermark\image\';
audio_files = dir('D:\workspace\python Workspace\watermark-gan\Steganography_GANs\dataset\music_dataset\16000\val\val_resample\*.wav');
audio_filenames = {audio_files.name};
embed_audio_toot = 'D:\workspace\python Workspace\watermark-gan\Steganography_GANs\dataset\music_dataset\16000\val\val_resample\';
% r=randperm( size(audio_filenames,2) );
% audio_filenames = audio_filenames(:, r);
image_files = dir('E:\worksapce\python_worksapce\matlab_audio_watermark\image\*.jpg');
image_filenames = {image_files.name};
avg_snr = 0;
avg_acc = zeros(8,1);
%my_lambda = zeros(100);
%the_lambda = zeros(100);
load('two_nine_lambda.mat');
for i=1:10
    audio_file = strcat(audio_root, audio_filenames(i));
    audio_file = audio_file{1,1};
    image_file = strcat(image_root, image_filenames(i));
    image_file = image_file{1,1};
    now_lambda = change_lambda(i,1);
    % now_lambda = lambda;
    oup = strcat(embed_audio_toot, audio_filenames(i));
    oup = oup{1,1}
    snr = embed(audio_file,oup,image_file,now_lambda)
%     while snr<25
%         now_lambda = now_lambda-0.001
%         snr = embed(audio_file,oup,image_file,now_lambda);
%     end
    %the_lambda(i) = now_lambda;
    avg_snr = avg_snr + snr;
    
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(1) = avg_acc(1) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack2.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(2) = avg_acc(2) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack3.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(3) = avg_acc(3) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack5.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(4) = avg_acc(4) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack6.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(5) = avg_acc(5) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack7.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(6) = avg_acc(6) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack8.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda);
    avg_acc(7) = avg_acc(7) + acc;
    %attack******************************
    [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack9.py');
    acc = extract(attacked,audio_file,image_file,img_output,now_lambda)
    avg_acc(8) = avg_acc(8) + acc;
end

avg_snr = avg_snr/100
avg_acc = avg_acc/100

save('macc_change_avg_acc.mat','avg_acc');

    

