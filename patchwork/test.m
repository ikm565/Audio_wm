[A,fs] = audioread('a.wav');
T=1/fs;
t=(1:length(A))*T;

subplot(211);
plot(t,A);

b= reshape(A,1,[]);
dct_a = dct(b);
for i=50000:529200
    dct_a(i) = 0;
end
c = idct(dct_a);
subplot(212);
plot(t,c);