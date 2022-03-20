function [res] = decrypt(watermark)
res = zeros(10,10);
cc = zeros(100);
c1 = 0.2;
c2 = 0;
for i=1:100
     c2 = pwnlcm_map(0.3,c1);	
     if c1 > 0.5
         cc(i) = 1;
     else cc(i) = 0;
     end
     watermark(i) = xor(watermark(i),cc(i));	%ªÏ„Áº”√‹ PWNLCM
     res(ceil(i/10),mod(i-1,10)+1) = watermark(i);
     c1 = c2;
end
