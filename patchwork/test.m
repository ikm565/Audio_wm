%% Test DCT
[A,fs] = audioread('a.wav');
% A = A(86:100);
T=1/fs;
t=(1:length(A))*T;

subplot(211);
plot(t,A);

b= reshape(A,1,[]);
dct_a = dct(b);
[ca,cb] = dwt(b,'db1');
for i=1:length(cb)
    ca(i) = 0;
end
c = idct(dct_a);
d = idwt(ca,cb,'db1');
subplot(212);
plot(t,d);
audiowrite('out.wav',d,fs);
a = [1;2;3;4;5;6;7;8;9;10;11;12];
b = reshape(a, 3,2,2,1);
b(:,1,1,1)
DCT = ones(3,2,2,1);
DCT(:,1,1,1) = b(:,1,1,1);
DCT(:,1,1,1)

%% Upsample Audio Dataset %%
file_path = '..\Audio_Datatset_some\'; %图像文件夹路径
img_path_list = dir(strcat(file_path,'*.wav'));
img_num  = length(img_path_list); %获取图像总数量
path = '..\Audio_Datatset_some\upsample\'; %处理后的图像保存路径
if img_num >0
    for j = 1:img_num
      image_name = img_path_list(j).name;%图像名
      [audio, sr]  = audioread(strcat(file_path,image_name));
      audio = resample(audio,44100,sr);%对图像进行遍历的处理代码，如：调整图像大小为227×227
      audiowrite([path,num2str(j),'.wav'],audio,44100);
    end
end
%% Show Audio Waveform %%
[A_,fs_A] = audioread('out.wav');
[B_,fs_B] = audioread('lla_out.wav');
[C_,fs_C] = audioread('lla_out_lenovo.wav');
len = 0;%6500;
shift = 200000;%157500;
leng = 300000;
A = A_(shift+1:shift+leng);
T=1;
t=(1:length(A))*T;
subplot(311);
plot(t,A);
title('original');

B = B_(len+shift+1:shift+len+leng);
t=(1:length(B))*T;
subplot(312);
plot(t,B);
title('xiaomi10');

C = C_(len+shift+1:shift+len+leng);
t=(1:length(C))*T;
subplot(313);
plot(t,C);
title('lenovo');
%% Save Audio
audiowrite('forward.wav',A,16000);
audiowrite('backward.wav',B,16000);
%% Test Resample
[audio, sr]  = audioread('..\Audio_Datatset_some\upsample\3.wav');
audio = resample(audio,88200,sr);%对图像进行遍历的处理代码，如：调整图像大小为227×227
len = 0;%6500;
shift = 200000;%157500;
leng = 3000;
A = audio(shift+1:shift+leng);
T=1;
t=(1:length(A))*T;
subplot(111);
plot(t,A);
title('original');
audiowrite('..\Audio_Datatset_some\resample.wav',audio,88200);
%% Test Resample Audio
%% Show Audio Waveform %%
[A_,fs_A] = audioread('out.wav');
[B_,fs_B] = audioread('lla_out.wav');
[C_,fs_C] = audioread('a_micro.wav');
len = 6560;%6500;
shift = 200000;%157500;
leng = 5000;
A = A_(shift+1:shift+leng);
T=1;
t=(1:length(A))*T;
hold on;
plot(t,A);
title('original');

C = C_(len+shift+1:shift+len+leng);
t=(1:length(C))*T;
plot(t,C);
title('lenovo');
hold off;