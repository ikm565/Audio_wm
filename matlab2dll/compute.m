function [obj] = compute(in_audio,in_img,lambda)
%ͬ����syn_code����
 syn_len = 32;
 syn_code = zeros(1,32);
 z1 = 0.01;
 z2 = 0;
 B = 0.5;
 thred = 0.1;
 
 for j = 1:syn_len
     if z1< (-1)*B && z1>= -1
        z2 = 1-2*z1*z1;
     elseif z1<0 && z1>=(-1)*B
        z2 = 1-0.5*((-2)*z1).^1.2;
     elseif z1<B && z1>=0
        z2 = 1-2*z1;
     elseif z1<=1 && z1>=B
        z2 = (-1)*(2*z1-1).^0.7;
     end
     if z1 > thred
        syn_code(j) =  1;
     else
		syn_code(j) = 0;
     end
     z1 = z2;
 end
 
 clear z1 z2 B thread;
 
 %�ֶη����Ի���ӳ��ϵͳ
 %��ˮӡ����ֵͼ�񣩽��л������
 %���룺ԭʼ�Ķ�ֵͼ��
 %��������ܺ�Ķ�ֵͼ��
 I = imread(in_img);
 bw=im2bw(I,0.8); %��Ϊ��ֵͼ��
 watermark = zeros(1,4096);
 r = 0.3;
 cc = zeros(1,4096);
 c1 = 0.2;
 c2 = 0;
 thred = 0.5;
 for i=1:4096
     if mod(i,64)==0
         watermark(i) = bw(ceil(i/64),64);
     else
        watermark(i) = bw(ceil(i/64),i-64*floor(i/64));	%��ά��ֵͼ��תΪһά����
     end
     c2 = pwnlcm_map(r,c1);
     if c1 > thred
        cc(i) = 1;
     else 
		cc(i) = 0;
     end
	 c1 = c2;
     watermark(i) = xor(watermark(i),cc(i));    %������� PWNLCM
 end
 watermark = watermark*1;
 
 clear I bw cc c1 c2;
 
 %��Ƶ�ֶ�ΪPA��PB��rest_audio
 %�ֶ���ǰ1024������PA����ͬ����Ƕ�룬ʣ�ಿ��PB����ˮӡǶ��
 %��Ƶ���һ�β����ֶγ��ȣ����浽rest_audio
 [source,fs]=audioread(in_audio);
 wat_num = 4;
 len = length(source);
 seg_len = 110000;
 seg_number = floor(len/seg_len);
 pa_len = 1024;
 audio_seg = zeros(seg_number,seg_len);
 PA = zeros(seg_number,pa_len);
 PB = zeros(seg_number,seg_len-pa_len);
 for k=1:seg_number
    audio_seg(k,:)=source((k-1)*seg_len+1:k*seg_len);
    PA(k,:) = audio_seg(k,1:pa_len);
    PB(k,:) = audio_seg(k,pa_len+1:seg_len);
 end
 rest_audio = source(seg_number*seg_len+1:len);
 
 clear audio_seg;

 %PAǶ��ͬ����
 %��ͬ������þ�ֵ�޸ĵķ���Ƕ�뵽PA
 %���룺 ��Ƶ�ֶ�PA��ͬ����syn_code,ͬ���볤��syn_len
 %����� Ƕ��ͬ�������Ƶ�ֶΣ���ʾΪPA_syn
 Q = 0.001; %Q��ʾǶ��ǿ��
 [m,n] = size(PA);
 syn_seg_len = n/syn_len;
 u = 1;
 k = floor(m/wat_num);
 PA_syn = PA;
 CPA = zeros(syn_len, syn_seg_len);
 for i=1:wat_num
    for j = 1:syn_len
        CPA(j,:) = PA((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len);
        if syn_code(j)==1
           CPA(j,u) = round(CPA(j,u)/Q)*Q;
        else 
           CPA(j,u) = floor(CPA(j,u)/Q)*Q+Q/2;
        end
        PA_syn((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len)=CPA(j,:);
    end
 end
 clear m n Q u k CPA;
	 
%��ˮӡǶ�뵽PB��Ƕ��ǿ��lambda
PB_watermark = embedding(lambda,PB,seg_number,watermark,wat_num);
test_audio = integrate(PA_syn,PB_watermark,rest_audio,seg_number);

clear rest_audio;

 %-----------------------������������˹��---------------------%
    GN_audio = awgn(test_audio,20);
    [ ~,GN_PB,~ ]=partition( GN_audio,seg_len,seg_number,pa_len,len );
    clear GN_audio;
    GN_watermark = watermark_extraction( seg_number,GN_PB,PB,lambda,wat_num,watermark );
    clear GN_PB;
    GN_BER = computeBER(GN_watermark,watermark);
    clear GN_watermark;   
    
 %--------------------------��ͨ�˲�����----------------------------%
    B =[0.0062,0.0187,0.0187,0.0062]; % ����ϵ��
    A =[1,-2.1706,1.6517,-0.4312]; % ��ĸϵ��
    LF_audio=filter(B,A,test_audio);
    [ ~,LF_PB,~ ]=partition( LF_audio,seg_len,seg_number,pa_len,len );
    clear A B LF_audio;
    LF_watermark = watermark_extraction( seg_number,LF_PB,PB,lambda,wat_num,watermark );  
    clear LF_PB;
    LF_BER = computeBER(LF_watermark,watermark);
    clear LF_watermark;
    
%------------------------ѹ������--------------------------%
    mp3write(test_audio,fs,'temp.mp3');
    MP_audio = mp3read('temp.mp3');
    [ ~,MP_PB,~] = partition( MP_audio,seg_len,seg_number,pa_len,len );
    clear MP_audio;
    MP_watermark = watermark_extraction( seg_number,MP_PB,PB,lambda,wat_num,watermark );
    clear MP_PB;
    MP_BER  = computeBER(MP_watermark,watermark);
    clear MP_watermark;

 %-----------------------����----------------------------------%
    CP_audio = test_audio;
    for i=5:400:len
        CP_audio(i) = 0;
    end
    [ ~,CP_PB,~ ]=partition( CP_audio,seg_len,seg_number,pa_len,len );
    clear i CP_audio;
    CP_watermark = watermark_extraction( seg_number,CP_PB,PB,lambda,wat_num,watermark );
    CP_BER = computeBER(CP_watermark,watermark);
    clear CP_PB;
    clear CP_watermark;

%-----------------------������------------------------%
    audiowrite('temp.wav',test_audio,fs,'BitsPerSample',8);
    [RQ_audio,fs]=audioread('temp.wav');
    [ ~,RQ_PB,~ ]=partition( RQ_audio,seg_len,seg_number,pa_len,len );
    clear RQ_audio;
    RQ_watermark = watermark_extraction( seg_number,RQ_PB,PB,lambda,wat_num,watermark );
    clear RQ_PB;
    RQ_BER = computeBER(RQ_watermark,watermark);
    clear RQ_watermark;

%------------------------�ز���------------------------%
    temp_audio = resample(test_audio,fs/2,fs); 
    RS_audio = resample(temp_audio,fs,fs/2); 
    clear temp_audio;
    [ ~,RS_PB,~ ]=partition( RS_audio,seg_len,seg_number,pa_len,len );
    clear RS_audio;
    RS_watermark = watermark_extraction( seg_number,RS_PB,PB,lambda,wat_num,watermark );
    clear RS_PB;
    RS_BER = computeBER(RS_watermark,watermark);
    clear RS_watermark;
    
 %------------------------��ֵ�˲�-----------------------------%
    MF_audio = medfilt1(test_audio,3);
    [ ~,MF_PB,~ ]=partition( MF_audio,seg_len,seg_number,pa_len,len );
    clear MF_audio;
    MF_watermark = watermark_extraction( seg_number,MF_PB,PB,lambda,wat_num,watermark );
    MF_BER = computeBER(MF_watermark,watermark);
    clear MF_PB MF_watermark;

%----------------------��ֵ�޸�-----------------------%

    AM_PB = PB_watermark*0.9;
    clear PB_watermark;
    AM_watermark = watermark_extraction( seg_number,AM_PB,PB,lambda,wat_num,watermark );
    clear AM_PB;
    AM_BER = computeBER(AM_watermark,watermark);
    clear AM_watermark;

    obj = zeros(1,2);
    obj(1) = (MP_BER+AM_BER+RQ_BER+RS_BER+GN_BER+LF_BER+MF_BER+CP_BER)/8;
    audiowrite('water.wav',test_audio,fs,'BitsPerSample',16);
    obj(2) = PQevalAudio(in_audio,'water.wav');
    
end