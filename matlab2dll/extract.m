function [acc_val] = extract(audio_input,ref_input,img_input,img_output,lambda)
%����ԭʼ��Ƶ��Ƕ��ˮӡ�����Ƶ����ȡ��PB��
[source,~]=audioread(audio_input);
[ref,~]=audioread(ref_input);
ref = ref(1:500000);
source = source(1:length(ref));
len = length(source);
len2 = length(ref);

if len ~= len2
    disp('ԭ��Ƶ��������Ƶ���Ȳ�ͬ����ȷ����Ƶ�����Ƿ���ȷ');
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
 %�ֶη����Ի���ӳ��ϵͳ
 %��ˮӡ����ֵͼ�񣩽��л������
 %���룺ԭʼ�Ķ�ֵͼ��
 %��������ܺ�Ķ�ֵͼ��
 %I = imread(img_input);
%bw=im2bw(I,0.8); %��Ϊ��ֵͼ��
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
        watermark(i) = bw(ceil(i/10),i-10*floor(i/10));	%��ά��ֵͼ��תΪһά����
     end
     c2 = pwnlcm_map(r,c1);
     if c1 > thred
        cc(i) = 1;
     else 
		cc(i) = 0;
     end
	 c1 = c2;
     watermark(i) = xor(watermark(i),cc(i));    %������� PWNLCM
 end
 watermark = watermark*1;
clear I bw cc;

 wat_num = 4;
 %��������Ƶ����ȡ���ܹ���ˮӡ
 %����ˮӡ��������
 raw_watermark = watermark_extraction( seg_number,PB,PB_ref,lambda,wat_num,watermark);
 acc_val = 1 - sum(xor(watermark,raw_watermark))/(10*10);
 fprintf("%s acc is: %f \n", audio_input, acc_val);
 % out_watermark=decrypt(raw_watermark);	%����ͼ��
 % imwrite(im2uint8(mat2gray(out_watermark)),img_output);
 %clear;
end