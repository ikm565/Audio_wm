function [ snr ] = computeSNR( ref_audio,test_audio )
%SNR Summary of this function goes here
%   Detailed explanation goes here
% I = wavread(ref_audio);
% In = wavread(test_audio);
% I = ref_audio;
% In = test_audio;
%Ps=sum(sum(ref_audio.^2));%signal power
%Pn=sum(sum((test_audio-ref_audio).^2));%noise power
Ps = mse(ref_audio);
Pn = mse(ref_audio-test_audio);
clear ref_audio test_audio;
snr=10*log10(Ps/Pn);
end

