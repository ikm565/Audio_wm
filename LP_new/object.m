function [object,SNR] = object(lambda,cover_audio,PB,PA,rest_audio,seg_len,seg_number,pa_len,fs,watermark)
%根据传入的参数值（position）完成水印的嵌入，得到含水印音频，并计算相应的适应度函数
%   输入：控制参数，载体音频，分段数
%   输出：适应度函数，相应的含音频水印
PB_watermark=embedding(lambda,PB,seg_number,watermark);
test_audio = integrate( PA,PB_watermark,rest_audio,seg_number );
SNR = computeSNR( test_audio,cover_audio );
M_corr = mValue1(test_audio,lambda,PB_watermark,PB,cover_audio,seg_len,pa_len,fs,watermark);
object = 2 * SNR * M_corr/(SNR + M_corr);
%end
% [MSNR,MNC] = mValue(position,audio_test,cover_audio,fs,watermark);
end

