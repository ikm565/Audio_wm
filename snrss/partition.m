function [ PA,PB,rest_audio ] = partition( cover_audio,seg_len,seg_number,pa_len,len )
%PARTITION Summary of this function goes here
%   Detailed explanation goes here
for i=1:seg_number
    audio_seg(i,:)=cover_audio((i-1)*seg_len+1:i*seg_len);
    %������Ƶ�����зֶ���ǰ1024������PA����ͬ����Ƕ�룬ʣ�ಿ��PB����ˮӡǶ��
    PA(i,:) = audio_seg(i,1:pa_len);
    PB(i,:) = audio_seg(i,pa_len+1:seg_len);
end
%��Ƶ���һ�β����ֶγ��ȣ����浽rest_audio
rest_audio = cover_audio(seg_number*seg_len+1:len);

end

