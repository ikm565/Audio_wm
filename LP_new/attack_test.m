%clear all;
%获取水印
watermark = pwnlcm('eg.jpg');
watermark = watermark *1;
%获取载体音频
[cover_audio,fs,nbits]=wavread('folk1.wav');
%测算音频长度
len=length(cover_audio);
% %音频分段数
% seg_number=24;
% %每段音频长度
% seg_len=fix(len/seg_number);    %fix()趋于0取整
% %seg_len = floor(seg_len/4)*4;
seg_len=10000;
seg_number=floor(len/seg_len);
%同步码长度
syn_len=32;
%生成同步码
syn_code = syn_generate(0.01,0.5,0.1,syn_len);
%payload
NP = seg_number/(len*nbits);
%用于嵌同步码的分段PA长度
pa_len = 1024;
%对音频分段
[ PA,PB,rest_audio ] = partition( cover_audio,seg_len,seg_number,pa_len,len );
%将同步码嵌入到PA
Q = 0.001; %Q表示嵌入强度
PA_syn = syn_embed(PA,syn_code,syn_len,Q);
% test_audio = integrate( PA_syn,PB,rest_audio,seg_number );
%将水印嵌入到PB，嵌入强度lambda
lambda = 0.42;
PB_watermark=embedding(lambda,PB,seg_number,watermark);
% w = watermark_extraction( seg_number,PB_watermark,PB,lambda );
% clear PB;
% w = decrypt(w);
test_audio = integrate( PA_syn,PB_watermark,rest_audio,seg_number );
SNR = computeSNR( test_audio,cover_audio );
% 
% %extract_watermark = extraction(lambda,Q,test_audio,cover_audio,syn_len);
% MBER = mValue(test_audio,lambda,PB_watermark,cover_audio,seg_number,pa_len,fs,watermark);
% wavwrite(test_audio,fs,16,'LP_audio.wav');

%------------------------压缩攻击--------------------------%
    mp3write(test_audio,fs,'temp.mp3');
    MP_audio = mp3read('temp.mp3');
    [ ~,MP_PB,~] = partition( MP_audio,seg_len,seg_number,pa_len,len );
    clear MP_audio;
    MP_watermark = watermark_extraction( seg_number,MP_PB,PB,lambda );
    MP=decrypt(MP_watermark);
    imwrite(im2uint8(mat2gray(MP)),'0.42MP.jpg');
    clear MP_PB;
    MP_BER  = computeBER(MP_watermark,watermark);
    MP_corr =  corr(MP_watermark,watermark);
    clear MP_watermark;
%-----------------------重量化------------------------%
    test_audio = integrate( PA,PB_watermark,rest_audio,seg_number );
    clear rest_audio PA;
    wavwrite(test_audio,fs,8,'temp.wav');
    [RQ_audio,fs,~]=wavread('temp.wav');
     [ ~,RQ_PB,~ ]=partition( RQ_audio,seg_len,seg_number,pa_len,len );
     clear RQ_audio;
    RQ_watermark = watermark_extraction( seg_number,RQ_PB,PB,lambda );
    RQ=decrypt(RQ_watermark);
    imwrite(im2uint8(mat2gray(RQ)),'0.42RQ.jpg');
    clear RQ_PB;
    RQ_BER = computeBER(RQ_watermark,watermark);
    RQ_corr =  corr(RQ_watermark,watermark);
    clear RQ_watermark;
% %----------------------幅值修改-----------------------%
    AM_PB = PB_watermark*0.9;
    clear PB_watermark;
    AM_watermark = watermark_extraction( seg_number,AM_PB,PB,lambda );
    AM=decrypt(AM_watermark);
    imwrite(im2uint8(mat2gray(AM)),'0.42AM.jpg');
    clear AM_PB;
    AM_BER = computeBER(AM_watermark,watermark);
    AM_corr =  corr(AM_watermark,watermark);
    clear AM_watermark;
%------------------------重采样------------------------%
    temp_audio = resample(test_audio,fs/2,fs); 
    RS_audio = resample(temp_audio,fs,fs/2); 
    clear temp_audio;
    [ ~,RS_PB,~ ]=partition( RS_audio,seg_len,seg_number,pa_len,len );
    clear RS_audio;
    RS_watermark = watermark_extraction( seg_number,RS_PB,PB,lambda );
    RS=decrypt(RS_watermark);
    imwrite(im2uint8(mat2gray(RS)),'0.42RS.jpg');
    clear RS_PB;
    RS_BER = computeBER(RS_watermark,watermark);
    RS_corr =  corr(RS_watermark,watermark);
    clear RS_watermark;
%-----------------------噪声攻击（高斯）---------------------%
    GN_audio = awgn(test_audio,30);
    [ ~,GN_PB,~ ]=partition( GN_audio,seg_len,seg_number,pa_len,len );
    clear GN_audio;
    GN_watermark = watermark_extraction( seg_number,GN_PB,PB,lambda );
    GN=decrypt(GN_watermark);
    imwrite(im2uint8(mat2gray(GN)),'0.42GN.jpg');
    clear GN_PB;
    GN_BER = computeBER(GN_watermark,watermark);
    GN_corr =  corr(GN_watermark,watermark);
    clear GN_watermark;

%--------------------------低通滤波攻击----------------------------%
%     B =[0.0062,0.0187,0.0187,0.0062]; % 分子系数
%     A =[1,-2.1706,1.6517,-0.4312]; % 分母系数
    B =[0.0062,0.0187,0.0187,0.0062]; % 分子系数
    A =[1,-2.1706,1.6517,-0.4312]; % 分母系数
    LF_audio=filter(B,A,test_audio);
    [ ~,LF_PB,~ ]=partition( LF_audio,seg_len,seg_number,pa_len,len );
    clear LF_audio;
    LF_watermark = watermark_extraction( seg_number,LF_PB,PB,lambda );  
    LF=decrypt(LF_watermark);
    imwrite(im2uint8(mat2gray(LF)),'0.42LF.jpg');
    clear LF_PB;
    LF_BER = computeBER(LF_watermark,watermark);
    LF_corr =  corr(LF_watermark,watermark);
    clear LF_watermark;
%------------------------中值滤波-----------------------------%

    MF_audio = medfilt1(test_audio,3);
    [ ~,MF_PB,~ ]=partition( MF_audio,seg_len,seg_number,pa_len,len );
    clear MF_audio;
    MF_watermark = watermark_extraction( seg_number,MF_PB,PB,lambda );
    MF=decrypt(MF_watermark);
    imwrite(im2uint8(mat2gray(MF)),'0.42MF.jpg');
    MF_BER = computeBER(MF_watermark,watermark);
    MF_corr =  corr(MF_watermark,watermark);
    clear MF_watermark;
 
%-----------------------剪裁----------------------------------%
    CP_audio = test_audio;
    for i=5:400:len
        CP_audio(i) = 0;
    end
    [ ~,CP_PB,~ ]=partition( CP_audio,seg_len,seg_number,pa_len,len );
    clear CP_audio;
    CP_watermark = watermark_extraction( seg_number,CP_PB,PB,lambda );
    CP=decrypt(CP_watermark);
    imwrite(im2uint8(mat2gray(CP)),'0.42CP.jpg');
    CP_BER = computeBER(CP_watermark,watermark);
    CP_corr =  corr(CP_watermark,watermark);
    clear CP_watermark;
%---------------------计算平均NC值----------------------------%
% MNC = (AM_NC+RQ_NC+RS_NC+GN_NC+LF_NC+MF_NC)/6;
%----------------------计算平均BER值--------------------------%
MBER = (MP_BER+AM_BER+RQ_BER+RS_BER+GN_BER+LF_BER+MF_BER+CP_BER)/8;
M_corr = (MP_corr+AM_corr+RQ_corr+RS_corr+GN_corr+LF_corr+MF_corr+CP_corr)/8;




