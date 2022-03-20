%获取水印
watermark = pwnlcm('eg.jpg');
watermark = watermark *1;
%%%%%记得修改音频名称！！！！
%获取载体音频
[cover_audio,fs,nbits]=wavread('folk6.wav');
%测算音频长度
len=length(cover_audio);
% %音频分段数
% seg_number=24;
% %每段音频长度
% seg_len=fix(len/seg_number);    %fix()趋于0取整
seg_len=110000;
seg_number=floor(len/seg_len);
%同步码长度
syn_len=32;
%生成同步码
syn_code = syn_generate(0.01,0.5,0.1,syn_len);
%payload
NP = seg_number/(len*nbits);
%用于嵌同步码的分段PA长度
pa_len = 1024;
%对音频分段
[ PA,PB,rest_audio ] = partition( cover_audio,seg_len,seg_number,pa_len,len );
%将同步码嵌入到PA
Q = 0.001; %Q表示嵌入强度
PA_syn = syn_embed(PA,syn_code,syn_len,Q);
min = 0;
max = 1;
snr_thred = 25;
delta = 1;
step = 0.001;
count = 0;
tic
%------通过snr_thred初步确定范围----------%
while delta>0.010001
     mid = (max+min)/2;
     lambda = roundn(mid,-2);
     PB_watermark=embedding(lambda,PB,seg_number,watermark);
     test_audio = integrate( PA,PB_watermark,rest_audio,seg_number );
     test_SNR = computeSNR( test_audio,cover_audio );
     if test_SNR<snr_thred
         max = lambda;
     else
         min = lambda;
     end
     delta = max - min;
     count = count +1
end

%----------以步长step通过线性规划找到近似最优解----------%
%初始化object
best_lamdba = min;
lambda = min;
[best_object,best_SNR] = object(best_lamdba,cover_audio,PB,PA,rest_audio,seg_len,seg_number,pa_len,fs,watermark);
while lambda<=max
    lambda = lambda+step;
    [test_object,test_SNR] = object(lambda,cover_audio,PB,PA,rest_audio,seg_len,seg_number,pa_len,fs,watermark);
    if best_object < test_object && test_SNR>=snr_thred
        best_object = test_object;
        best_lamdba = lambda;
    end
    count = count +1
end
toc
PB_watermark=embedding(best_lamdba,PB,seg_number,watermark);
best_audio = integrate( PA,PB_watermark,rest_audio,seg_number );
SNR = computeSNR( best_audio,cover_audio );
[MBER,M_corr] =mValue(test_audio,best_lamdba,PB_watermark,PB,cover_audio,seg_len,pa_len,fs,watermark);
%%%%记得修改音频名称！！！！
wavwrite(best_audio,fs,16,'LP_test5.wav');







