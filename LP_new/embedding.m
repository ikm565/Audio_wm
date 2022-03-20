function [ PB_watermark ] = embedding(lambda,PB,seg_number,watermark)
%EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
[Uw,Sw,Vw]=svd(watermark);
P=Sw*Vw';
% clear Vw;
% P=Uw*Sw;
% clear Uw Sw watermark;
k=floor(seg_number/4);
PB_watermark=PB;
for i=1:4
    %用db1小波对PB进行三级小波分解
    [A,D]=wavedec(PB((i-1)*k+1,:),3,'db1');
    appro=appcoef(A,D,'db1',3);%近似分量
    d3=detcoef(A,D,3);%细节分量
    d2=detcoef(A,D,2);
    d1=detcoef(A,D,1);
    d_appro = dct(appro);
    clear A appro;
    %对近似分量中SVD
    [U,S,V] = svd(d_appro);
    clear d_appro;
    %采用扩频技术嵌入水印
    S1 = S;
    S1(1:1024) = S(1:1024) + (lambda*P((i-1)*1024+1:i*1024));
    d_appro1 = U*S1*V';
    clear U S S1 V;
    %重构近似分量
    appro1 = idct(d_appro1);
    clear d_appro1;
    A1=[appro1,d3,d2,d1];
    clear appro1 d3 d2 d1;
    %逆小波变换
    PB_watermark((i-1)*k+1,:)=waverec(A1,D,'db1');
    clear A1;
end
end

