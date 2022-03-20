function [ snr ] = embed(in_audio,out_audio,in_img,lambda)
%同步码syn_code生成
 syn_len = 32;
 syn_code = zeros(1,32);
 z1 = 0.01;
 z2 = 0;
 B = 0.5;
 thred = 0.1;
 for j = 1:syn_len
     if z1< (-1)*B && z1>= -1
        z2 = 1-2*z1*z1;
     elseif z1<0 && z1>=(-1)*B
        z2 = 1-0.5*((-2)*z1).^1.2;
     elseif z1<B && z1>=0
        z2 = 1-2*z1;
     elseif z1<=1 && z1>=B
        z2 = (-1)*(2*z1-1).^0.7;
     end
     if z1 > thred
        syn_code(j) =  1;
     else
		syn_code(j) = 0;
     end
     z1 = z2;
 end
 
 clear z1 z2 B thread;
 
 %分段非线性混沌映射系统
 %对水印（二值图像）进行混沌加密
 %输入：原始的二值图像
 %输出：加密后的二值图像
 %I = imread(in_img);
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
 
 clear I bw cc c1 c2;
 
 %音频分段为PA，PB，rest_audio
 %分段中前1024个样本PA用于同步码嵌入，剩余部分PB用于水印嵌入
 %音频最后一段不够分段长度，保存到rest_audio
 [source,fs]=audioread(in_audio);
 source = source(1:500000);
%  source = source(:,2);
 wat_num = 4;
 len = length(source);
 seg_len = 110000;
 seg_number = floor(len/seg_len);
 pa_len = 1024;
 audio_seg = zeros(seg_number,seg_len);
 PA = zeros(seg_number,pa_len);
 PB = zeros(seg_number,seg_len-pa_len);
 for k=1:seg_number
    audio_seg(k,:)=source((k-1)*seg_len+1:k*seg_len);
    PA(k,:) = audio_seg(k,1:pa_len);
    PB(k,:) = audio_seg(k,pa_len+1:seg_len);
 end
 rest_audio = source(seg_number*seg_len+1:len);
 
 clear audio_seg;

 %PA嵌入同步码
 %将同步码采用均值修改的方法嵌入到PA
 %输入： 音频分段PA，同步码syn_code,同步码长度syn_len
 %输出： 嵌入同步码的音频分段，表示为PA_syn
 Q = 0.001; %Q表示嵌入强度
 [m,n] = size(PA);
 syn_seg_len = n/syn_len;
 u = 1;
 k = floor(m/wat_num);
 PA_syn = PA;
 CPA = zeros(syn_len, syn_seg_len);
 for i=1:wat_num
    for j = 1:syn_len
        CPA(j,:) = PA((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len);
        if syn_code(j)==1
           CPA(j,u) = round(CPA(j,u)/Q)*Q;
        else 
           CPA(j,u) = floor(CPA(j,u)/Q)*Q+Q/2;
        end
        PA_syn((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len)=CPA(j,:);
    end
 end
 clear m n Q u k CPA;
	 
%将水印嵌入到PB，嵌入强度lambda
wat_num = 4;
PB_watermark = embedding(lambda,PB,seg_number,watermark,wat_num);
out = integrate(PA_syn,PB_watermark,rest_audio,seg_number);
audiowrite(out_audio,out,fs);
%clear;
source_mse = reshape(source,1,[]);
snr = 10*log10((mse(source_mse)/mse(source_mse-out)));
end