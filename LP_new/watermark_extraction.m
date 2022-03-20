function [ watermark ] = watermark_extraction( seg_number,test_PB,ref_PB,lambda )
%WATERMARK_EXTRACTION Summary of this function goes here
%   Detailed explanation goes here
original = pwnlcm('eg.jpg');
original = original *1;
[Uw,~,Vw] = svd(original);
k=floor(seg_number/4);
for i=1:4
%     [Uw,Sw,Vw] = svd(original(i,:));
    [test_A,test_D]=wavedec(test_PB((i-1)*k+1,:),3,'db1');
    [ref_A,ref_D]=wavedec(ref_PB((i-1)*k+1,:),3,'db1');
    test_appro=appcoef(test_A,test_D,'db1',3);%½üËÆ·ÖÁ¿
    clear test_A test_D;
    ref_appro=appcoef(ref_A,ref_D,'db1',3);
    clear ref_A ref_D;
    d_test_appro = dct(test_appro);
    d_ref_appro = dct(ref_appro);
    diff=d_ref_appro-d_test_appro;
    clear test_appro;
    [U,~,V] = svd(d_ref_appro);
    clear d_ref_appro;
    P = (U*diff*V')/lambda;
    watermark((i-1)*1024+1:i*1024)=Uw*P(1:1024);
%     watermark(i,:) = W*Vw;
end
%     watermark = W*Vw';
    watermark = abs(round(watermark));
    for j=1:4096
        if watermark(j)>1 
            watermark(j)=1;
        end
    end
end

