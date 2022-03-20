function [ PB_watermark ] = embedding(lambda,PB,seg_number,watermark,wat_num)
%EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
% [Uw,Sw,Vw]=svd(watermark);
% P=Sw*Vw';
P = -watermark;
fprintf("watermark 's length is %d", length(P))
%1x4096
k=floor(seg_number/wat_num);
%6
PB_watermark=PB;
%24x108976
for i=1:wat_num
    %用db1小波对PB进行三级小波分解
    [A,D]=wavedec(PB((i-1)*k+1,:),3,'db1');
    appro=appcoef(A,D,'db1',3);%近似分量    
    d3=detcoef(A,D,3);%细节分量
    d2=detcoef(A,D,2);
    d1=detcoef(A,D,1);
    d_appro = dct(appro);
    d_appro = single(d_appro);
    %对近似分量的dct系数进行SVD 
    %13622
    [U,S,V] = svd(d_appro);
    %采用扩频技术嵌入水印
    S1 = S;
    S1(1:25) = S(1:25) + (lambda*P((i-1)*25+1:i*25));
    d_appro1 = U*S1*V'; %重构DCT系数
    %IDCT得到近似分量
    appro1 = idct(d_appro1);
    A1=[appro1,d3,d2,d1];
    %逆小波变换
    PB_watermark((i-1)*k+1,:)=waverec(A1,D,'db1');
end

end