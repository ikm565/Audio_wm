function [w] = pwnlcm(image)
%�ֶη����Ի���ӳ��ϵͳ
%��������Ҫ�����Ƕ�ˮӡ����ֵͼ�񣩽��л������
%���룺ԭʼ�Ķ�ֵͼ��
%��������ܺ�Ķ�ֵͼ��
    I = imread(image);
    bw=im2bw(I,0.8);
    key4 = 0.3;
    key5 = 0.2;
    key6 = 0.5;
    
    r = key4;
    c(1) = key5;
    thred = key6;
    for i=1:4096
        if mod(i,64)==0
            w(i)= bw(ceil(i/64),64);
        else
        w(i) = bw(ceil(i/64),i-64*floor(i/64));
        end
        c(i+1) = pwnlcm_map(r,c(i));
        if c(i) > thred
            cc(i) = 1;
        else cc(i) = 0;
        end
        w(i) = xor(w(i),cc(i));
%         if mod(i,64)==0
%             bw_new(ceil(i/64),64)=w(i);
%         else
% %         bw_new(ceil(i/64),i-64*floor(i/64))=w(i);
%         end
    end  
%     w=w';
%     imshow(bw_new);
     %imwrite(im2uint8(mat2gray(bw_new)),'encryped.jpg');
end


    
    