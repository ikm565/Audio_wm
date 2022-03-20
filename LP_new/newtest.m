clear all;
%获取水印
watermark = pwnlcm('eg.jpg');
watermark = watermark *1;
%获取载体音频
[cover_audio,fs,nbits]=wavread('pop.wav');
%测算音频长度
len=length(cover_audio);
% %音频分段数
% seg_number=64;
% %每段音频长度
% seg_len=fix(len/seg_number);    %fix()趋于0取整
% % seg_len = floor(seg_len/4)*4;
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
% test_audio = integrate( PA_syn,PB,rest_audio,seg_number );
%将水印嵌入到PB，嵌入强度lambda

lambda = 0.30;
step=0.05;
while lambda<=1
    lambda=lambda+step
    PB_watermark=embedding(lambda,PB,seg_number,watermark);
    test_audio = integrate( PA_syn,PB_watermark,rest_audio,seg_number );
    SNR = computeSNR( test_audio,cover_audio )
    [MBER,M_corr] = mValue(test_audio,lambda,PB_watermark,PB,cover_audio,seg_len,pa_len,fs,watermark)
end




