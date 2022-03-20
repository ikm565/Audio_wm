function [ BER ] = computeBER( test_watermark, orignal_watermark )
%NC Summary of this function goes here
%   Detailed explanation goes here
[m1,n1] = size(test_watermark);
[m2,n2] = size(orignal_watermark);
if m1==m2&&n1==n2
    X=0;
    for i=1:m1
        for j=1:n1
        X = X+xor(test_watermark(i,j),orignal_watermark(i,j));
        end
    end
else  error('水印长度不同!');  
end
    BER = X/(m1*n1);
end

