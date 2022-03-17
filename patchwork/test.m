% [A,fs] = audioread('a.wav');
% % A = A(86:100);
% T=1/fs;
% t=(1:length(A))*T;
% 
% subplot(211);
% plot(t,A);
% 
% b= reshape(A,1,[]);
% dct_a = dct(b);
% [ca,cb] = dwt(b,'db1');
% for i=1:length(cb)
%     ca(i) = 0;
% end
% c = idct(dct_a);
% d = idwt(ca,cb,'db1');
% subplot(212);
% plot(t,d);
% audiowrite('out.wav',d,fs);
a = [1;2;3;4;5;6;7;8;9;10;11;12];
b = reshape(a, 3,2,2,1);
b(:,1,1,1)
DCT = ones(3,2,2,1);
DCT(:,1,1,1) = b(:,1,1,1);
DCT(:,1,1,1)
