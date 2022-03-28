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
% a = [1;2;3;4;5;6;7;8;9;10;11;12];
% b = reshape(a, 3,2,2,1);
% b(:,1,1,1)
% DCT = ones(3,2,2,1);
% DCT(:,1,1,1) = b(:,1,1,1);
% DCT(:,1,1,1)

[A_,fs] = audioread('out.wav');
[B_,fs] = audioread('lla_out.wav');
len = 8000;
A = A_(1:5000)/10;
T=1;
t=(1:length(A))*T;
subplot(211);
plot(t,A);

B = B_(500000:500000+7000);
t=(1:length(B))*T;
subplot(212);
plot(t,B);

[B_,fs] = audioread('lla_out.wav');
B1 = B_(507000-100000:507000);
B2 = A_(500000-100000:500000)/5;
audiowrite('forward.wav',B1,16000);
audiowrite('backward.wav',B2,16000);

