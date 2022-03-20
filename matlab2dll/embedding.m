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
    %��db1С����PB��������С���ֽ�
    [A,D]=wavedec(PB((i-1)*k+1,:),3,'db1');
    appro=appcoef(A,D,'db1',3);%���Ʒ���    
    d3=detcoef(A,D,3);%ϸ�ڷ���
    d2=detcoef(A,D,2);
    d1=detcoef(A,D,1);
    d_appro = dct(appro);
    d_appro = single(d_appro);
    %�Խ��Ʒ�����dctϵ������SVD 
    %13622
    [U,S,V] = svd(d_appro);
    %������Ƶ����Ƕ��ˮӡ
    S1 = S;
    S1(1:25) = S(1:25) + (lambda*P((i-1)*25+1:i*25));
    d_appro1 = U*S1*V'; %�ع�DCTϵ��
    %IDCT�õ����Ʒ���
    appro1 = idct(d_appro1);
    A1=[appro1,d3,d2,d1];
    %��С���任
    PB_watermark((i-1)*k+1,:)=waverec(A1,D,'db1');
end

end