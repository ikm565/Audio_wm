function [ test_audio ] = integrate( PA,PB,rest_audio,seg_number )
%INTEGRATE Summary of this function goes here
%   Detailed explanation goes here
[PA_m,PA_n]=size(PA);
[PB_m,PB_n]=size(PB);
rest_len = length(rest_audio);
seg_len = PA_n + PB_n;
for i=1:seg_number
    audio_seg(1:PA_n) = PA(i,:);
    audio_seg(PA_n+1:PA_n+PB_n)= PB(i,:);
    test_audio((i-1)*seg_len+1:i*seg_len) = audio_seg;
end
test_audio = test_audio';
test_audio(seg_number*seg_len+1:seg_number*seg_len+rest_len)=rest_audio;
end

