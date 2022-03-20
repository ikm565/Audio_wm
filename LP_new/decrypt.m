function [ bw_new ] = decrypt( w )
key4 = 0.3;
key5 = 0.2;
key6 = 0.5;
r = key4;
c(1) = key5;
thred = key6;
d=64;%二值图像的规模为d*d
%[m,n] = size(watermark);
len=length(w);
for i=1:len
%     if mod(i,d)==0
%         w(i)=watermark(ceil(i/d),d);
%     else
%         w(i) = watermark(ceil(i/d),i-d*floor(i/d));
%     end
    c(i+1) = pwnlcm_map(r,c(i));
    if c(i) > thred
            cc(i) = 1;
    else cc(i) = 0;
    end
    w(i) = xor(w(i),cc(i));
    if mod(i,d)==0
        bw_new(ceil(i/d),d)=w(i);
    else
        bw_new(ceil(i/d),i-d*floor(i/d))=w(i);
    end
end
    %bw_new=reshape(w,64,64);
   imshow(bw_new);
%     imwrite(im2uint8(mat2gray(bw_new)),'encryped_watermark.jpg');
end

