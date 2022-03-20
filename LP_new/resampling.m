%��ȡˮӡ
watermark = pwnlcm('eg.jpg');
watermark=watermark*1;
%��ȡ������Ƶ
[cover_audio,fs,nbits]=wavread('test.wav');
%������Ƶ����
len=length(cover_audio);
%��Ƶ�ֶ���
% seg_number=8;
% %ÿ����Ƶ����
% seg_len=fix(len/seg_number);    %fix()����0ȡ��
% % seg_len = floor(seg_len/4)*4;
seg_len=110000;
seg_number=floor(len/seg_len);
%ͬ���볤��
syn_len=32;
%����ͬ����
syn_code = syn_generate(0.01,0.5,0.1,syn_len);
%payload
NP = seg_number/(len*nbits);
%����Ƕͬ����ķֶ�PA����
pa_len = 1024;
%����Ƶ�ֶ�
[ PA,PB,rest_audio ] = partition( cover_audio,seg_len,seg_number,pa_len,len );
%��ͬ����Ƕ�뵽PA
Q = 0.001; %Q��ʾǶ��ǿ��
PA_syn = syn_embed(PA,syn_code,syn_len,Q);
% test_audio = integrate( PA_syn,PB,rest_audio,seg_number );
%��ˮӡǶ�뵽PB��Ƕ��ǿ��lambda
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

