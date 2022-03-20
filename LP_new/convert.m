function [ B ] = convert( A )
%将矩阵转换为向量
[m,n] = size(A);
for i = 1:m
    for j=1:n
        B((i-1)*n+j)=A(i,j);
    end
end
end

