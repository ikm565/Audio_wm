function [ B ] = convert( A )
%������ת��Ϊ����
[m,n] = size(A);
for i = 1:m
    for j=1:n
        B((i-1)*n+j)=A(i,j);
    end
end
end

