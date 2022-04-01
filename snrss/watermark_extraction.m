function [ watermark1 ] = watermark_extraction( seg_number,test_PB,ref_PB,lambda,wat_num,watermark )

 % [Uw,~,~] = svd(watermark);

 k=floor(seg_number/wat_num);

for i=1:wat_num
	%db1С�� �� ����С���ֽ�
    [test_A,test_D]=wavedec(test_PB((i-1)*k+1,:),3,'db1');
    [ref_A,ref_D]=wavedec(ref_PB((i-1)*k+1,:),3,'db1');

	%�õ����Ʒ���
    test_appro=appcoef(test_A,test_D,'db1',3);
    ref_appro=appcoef(ref_A,ref_D,'db1',3);

	%���Ʒ�������DCT�任���õ�ϵ��
    d_test_appro = dct(test_appro);
    d_ref_appro = dct(ref_appro);
    d_ref_appro = single(d_ref_appro);
    
	%�������ź�DCTϵ���Ĳ�ֵ
    diff=d_ref_appro-d_test_appro;
    [U,~,V] = svd(d_ref_appro);

    
	%�õ�ˮӡ�� 1/wat_num
    P = (U*diff*V')/lambda;
    % watermark1((i-1)*1024+1:i*1024) = Uw*P(1:1024);
    watermark1((i-1)*25+1:i*25) = P(1:25);
end

    watermark1 = abs(round(watermark1));
    for j=1:100
        if watermark1(j)>1 
            watermark1(j)=1;
        end
    end
end

