function [ x ] = syn_generate(key1,key2,key3,syn_len)
%��������Ҫ�����Ƕ�ͬ���źŽ��л������
%  ���룺ԭʼ��ͬ���źţ���Կkey1,key2 ��key3
%  ��������ܺ��ͬ���ź�
    %y = dec2bin(original_syn,16);
%     key1 = 0.01;
%     key2 = 0.5;
%     key3 = 0.1;

    z(1) = key1;
    B = key2;
    thred = key3;

%     L_syn = length(y);
    
    for i = 1:syn_len
        if z(i)< (-1)*B && z(i)>= -1
            z(i+1) = 1-2*z(i)*z(i);
        elseif z(i)<0 && z(i)>=(-1)*B
            z(i+1) = 1-0.5*((-2)*z(i)).^1.2;
        elseif z(i)<B && z(i)>=0
            z(i+1) = 1-2*z(i);
        elseif z(i)<=1 && z(i)>=B
            z(i+1) = (-1)*(2*z(i)-1).^0.7;
        end  
        if z(i) > thred
            x(i) =  1;
        else x(i) = 0;
        end
    end
end

