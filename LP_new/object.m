function [object,SNR] = object(lambda,cover_audio,PB,PA,rest_audio,seg_len,seg_number,pa_len,fs,watermark)
%���ݴ���Ĳ���ֵ��position�����ˮӡ��Ƕ�룬�õ���ˮӡ��Ƶ����������Ӧ����Ӧ�Ⱥ���
%   ���룺���Ʋ�����������Ƶ���ֶ���
%   �������Ӧ�Ⱥ�������Ӧ�ĺ���Ƶˮӡ
PB_watermark=embedding(lambda,PB,seg_number,watermark);
test_audio = integrate( PA,PB_watermark,rest_audio,seg_number );
SNR = computeSNR( test_audio,cover_audio );
M_corr = mValue1(test_audio,lambda,PB_watermark,PB,cover_audio,seg_len,pa_len,fs,watermark);
object = 2 * SNR * M_corr/(SNR + M_corr);
%end
% [MSNR,MNC] = mValue(position,audio_test,cover_audio,fs,watermark);
end

