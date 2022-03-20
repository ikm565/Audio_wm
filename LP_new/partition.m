function [ PA,PB,rest_audio ] = partition( cover_audio,seg_len,seg_number,pa_len,len )
%PARTITION Summary of this function goes here
%   Detailed explanation goes here
for i=1:seg_number
    audio_seg(i,:)=cover_audio((i-1)*seg_len+1:i*seg_len);
    %划分音频，其中分段中前1024个样本PA用于同步码嵌入，剩余部分PB用于水印嵌入
    PA(i,:) = audio_seg(i,1:pa_len);
    PB(i,:) = audio_seg(i,pa_len+1:seg_len);
end
%音频最后一段不够分段长度，保存到rest_audio
rest_audio = cover_audio(seg_number*seg_len+1:len);

end

