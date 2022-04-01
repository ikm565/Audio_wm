function [ snr ] = embed(in_audio,out_audio,in_img,lambda)
%ͬ����syn_code����
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
 
 %�ֶη����Ի���ӳ��ϵͳ
 %��ˮӡ����ֵͼ�񣩽��л������
 %���룺ԭʼ�Ķ�ֵͼ��
 %��������ܺ�Ķ�ֵͼ��
 %I = imread(in_img);
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
 
 clear I bw cc c1 c2;
 
 %��Ƶ�ֶ�ΪPA��PB��rest_audio
 %�ֶ���ǰ1024������PA����ͬ����Ƕ�룬ʣ�ಿ��PB����ˮӡǶ��
 %��Ƶ���һ�β����ֶγ��ȣ����浽rest_audio
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

 %PAǶ��ͬ����
 %��ͬ������þ�ֵ�޸ĵķ���Ƕ�뵽PA
 %���룺 ��Ƶ�ֶ�PA��ͬ����syn_code,ͬ���볤��syn_len
 %����� Ƕ��ͬ�������Ƶ�ֶΣ���ʾΪPA_syn
 Q = 0.001; %Q��ʾǶ��ǿ��
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
	 
%��ˮӡǶ�뵽PB��Ƕ��ǿ��lambda
wat_num = 4;
PB_watermark = embedding(lambda,PB,seg_number,watermark,wat_num);
out = integrate(PA_syn,PB_watermark,rest_audio,seg_number);
audiowrite(out_audio,out,fs);
%clear;
source_mse = reshape(source,1,[]);
snr = 10*log10((mse(source_mse)/mse(source_mse-out)));
end