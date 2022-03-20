function [ corr_value ] = corr( A,B )
% A=convert( A1 );
% B= convert( B1 );
m=length(A);
n=length(B);
a = 0;
b = 0;
c = 0;
if m ~= n
    corr_value = 0;
else 
    mean_A = sum(A)/m;
    mean_B = sum(B)/n;
    for i=1:m
        a=a+(B(i)- mean_B)*(A(i)-mean_A);
        b=b+(A(i)-mean_A)*(A(i)-mean_A);
        c=c+(B(i)- mean_B)*(B(i)-mean_B);
    end
    corr_value = a/(sqrt(b)*sqrt(c));
end

end

