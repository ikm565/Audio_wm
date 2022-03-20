function [ w ] = extraction(lambda,Q,test_audio,ref_audio,syn_len)
% syn_len =16;
len_test=length(test_audio);
len_ref=length(ref_audio);
if len_test ~= len_ref
    error('音频长度不同，请检查相关音频文件是否正确！');
else len = len_test;   
end
syn_code = syn_generate(0.01,0.5,0.1,syn_len);
j = 1;
i=1;
while i<len-1024
    temp = test_audio(i:i+1024-1);
    syn_extract = syn_extraction(temp,Q,syn_len );
    corr_value = corr(syn_code,syn_extract);
    if corr_value>0.9
        index(j) = i;
        i = i+1024;
        j=j+1; 
    else i=i+1;
    end
end
seg_number=j-1;
for i=1:seg_number-1
    test_PB(i,:) = test_audio(index(i)+1024:index(i+1)-1);
    ref_PB(i,:) = ref_audio(index(i)+1024:index(i+1)-1);
end
gap = index(seg_number)-index(seg_number-1);
test_PB(seg_number,:) = test_audio(index(seg_number)+1024:index(seg_number)+gap-1);
ref_PB(seg_number,:) = ref_audio(index(seg_number)+1024:index(seg_number)+gap-1);
watermark = watermark_extraction( seg_number,test_PB,ref_PB,lambda );
w = decrypt(watermark);
end

