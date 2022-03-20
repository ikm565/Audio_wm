%��ȡˮӡ
watermark = pwnlcm('eg.jpg');
watermark=watermark*1;
%��ȡ������Ƶ
[cover_audio,fs,nbits]=wavread('classical.wav');
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
lambda = 0.2;
PB_watermark=embedding(lambda,PB,seg_number,watermark);
extract_watermark = watermark_extraction( seg_number,PB_watermark,PB,lambda );
w = decrypt(extract_watermark);
test_audio = integrate( PA_syn,PB_watermark,rest_audio,seg_number );
SNR = computeSNR( test_audio,cover_audio )
% wavwrite(test_audio,fs,16,'LP_audio.wav');
audiowrite('LP_audio.wav',test_audio,fs,'BitsPerSample',16);
% extract_watermark = extraction(lambda,Q,test_audio,cover_audio,syn_len);
[MBER,M_corr] = mValue(test_audio,lambda,PB_watermark,PB,cover_audio,seg_len,pa_len,fs,watermark);




