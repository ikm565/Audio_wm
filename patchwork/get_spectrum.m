[audioIn,fs] = audioread('lla_out.wav');
audioIn = audioIn(1:500000);
S = melSpectrogram(audioIn,fs);

[numBands,numFrames] = size(S);
fprintf("Number of bandpass filters in filterbank: %d\n",numBands);
figure;
subplot(311);
melSpectrogram(audioIn,fs);

[B_,fs_B] = audioread('lla_out.wav');
[C_,fs_C] = audioread('lla_out_lenovo.wav');
subplot(312);
melSpectrogram(B_,fs);
subplot(313);
melSpectrogram(C_,fs);
