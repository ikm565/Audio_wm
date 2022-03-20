function [acc_val] = attacked_extract(audio_input,ref_input,img_input,img_output,lambda)
%读入原始音频和嵌入水印后的音频，读取其PB段
acc_val = 0;
[source_root,~]=audioread(audio_input);
[ref,~]=audioread(ref_input);
ref = ref(1:500000);
for shift = -317560:-317559
    if abs(shift) > 3000
       source = zeros(1,500000);
       source(1:length(source)+shift+3000) = source_root(-shift+1:length(source_root));
    else
      source = source_root(-shift:length(ref)-shift-1);
    end
    len = length(source);
    len2 = length(ref);

    if len ~= len2
        disp('原音频与输入音频长度不同，请确认音频输入是否正确');
        return;
    end

    seg_len = 110000;
    seg_number = floor(len/seg_len);
    pa_len = 1024;
    audio_seg = zeros(seg_number,seg_len);
    ref_seg = zeros(seg_number,seg_len);
    PB = zeros(seg_number,seg_len-pa_len);
    PB_ref = zeros(seg_number,seg_len-pa_len);
    for k=1:seg_number
       audio_seg(k,:)=source((k-1)*seg_len+1:k*seg_len);
       ref_seg(k,:)=ref((k-1)*seg_len+1:k*seg_len);
       PB(k,:) = audio_seg(k,pa_len+1:seg_len);
       PB_ref(k,:) = ref_seg(k,pa_len+1:seg_len);
    end
    clear audio_seg ref_seg;
     %分段非线性混沌映射系统
     %对水印（二值图像）进行混沌加密
     %输入：原始的二值图像
     %输出：加密后的二值图像
     %I = imread(img_input);
     %bw=im2bw(I,0.8); %变为二值图像
     bw = [0, 1, 1, 1, 0, 1, 0, 0, 0, 1;...
        1, 0, 1, 0, 0, 0, 0, 1, 1, 0;...
        0, 1, 0, 1, 0, 0, 1, 0, 0, 0;...
        0, 0, 0, 1, 1, 1, 0, 1, 1, 1;...
        0, 1, 1, 0, 1, 1, 0, 1, 0, 0;...
        1, 0, 0, 0, 0, 1, 1, 0, 0, 0;...
        1, 1, 0, 1, 1, 1, 1, 0, 1, 1;...
        0, 1, 1, 0, 0, 0, 1, 1, 0, 1;...
        1, 1, 0, 1, 1, 0, 0, 0, 0, 0;...
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
     bw = logical(bw);
     watermark = zeros(1,100);
     r = 0.3;
     cc = zeros(1,100);
     c1 = 0.2;
     c2 = 0;
     thred = 0.5;
     for i=1:100
         if mod(i,10)==0
             watermark(i) = bw(ceil(i/10),10);
         else
            watermark(i) = bw(ceil(i/10),i-10*floor(i/10));	%二维二值图像转为一维数组
         end
         c2 = pwnlcm_map(r,c1);
         if c1 > thred
            cc(i) = 1;
         else 
            cc(i) = 0;
         end
         c1 = c2;
         watermark(i) = xor(watermark(i),cc(i));    %混沌加密 PWNLCM
     end
     watermark = watermark*1;
    clear I bw cc;

     wat_num = 4;
     %从输入音频中提取加密过的水印
     %解密水印，并保存
     raw_watermark = watermark_extraction( seg_number,PB,PB_ref,lambda,wat_num,watermark)
     acc_val_candidate = 1 - sum(xor(watermark,raw_watermark))/(10*10);
     fprintf("shift:%d 's acc is %f \n", shift, acc_val_candidate)
     if acc_val<acc_val_candidate
         acc_val = acc_val_candidate;
     end
     % out_watermark=decrypt(raw_watermark);	%解密图像
     % imwrite(im2uint8(mat2gray(out_watermark)),img_output);
     %clear;
end
end