%获取水印
watermark = pwnlcm('eg.jpg');
watermark=watermark*1;
%获取载体音频
[cover_audio,fs,nbits]=wavread('test.wav');
%测算音频长度
len=length(cover_audio);
%音频分段数
% seg_number=8;
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
lambda = 0.421;

%**************************%
fs2=fs*2;
%**************************%
PB_watermark=embedding(lambda,PB,seg_number,watermark);
test_audio = integrate( PA_syn,PB_watermark,rest_audio,seg_number );
    
temp_audio = resample(test_audio,fs2,fs); 
clear test_audio;
RS_audio = resample(temp_audio,fs,fs2); 
clear temp_audio;
[ ~,RS_PB,~ ]=partition( RS_audio,seg_len,seg_number,pa_len,len );
clear RS_audio;
RS_watermark = watermark_extraction( seg_number,RS_PB,PB,lambda );
RS=decrypt(RS_watermark);
%     imwrite(im2uint8(mat2gray(RS)),'0.401RS.jpg');
clear RS_PB;
RS_BER = computeBER(RS_watermark,watermark);
RS_corr =  corr(RS_watermark,watermark);
clear RS_watermark;

