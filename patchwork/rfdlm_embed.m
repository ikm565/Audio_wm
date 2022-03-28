function [ snr, N, M, G,Q_F_W,Q_feature ] = rfdlm_embed(length_audio,in_audio,out_audio,watermark,delta)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    snr = 0;
    [A,fs]=audioread(in_audio);
%     [A,fs]=mp3read(in_audio);
    A = reshape(A,[],1);
    A = A(1:length_audio); %529200
%     %W_LEN = length(watermark);
    %form three segments
    
    %divide A into N equal length frames
    %and Ai into M segments, Ai,m, m = 1, 2,..., M,
    %and form two groups from Ai,m as follows:
    N = 2;% frame count
    M = 3;% every frame embed two synchronization codes and one watermark bits 2+1=3
    G = 2;%every segment is formed into 2 group linked to each other(consecutive group)
    [N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num] = distribute(watermark);
    La = length(A);
    segment_count = N*M;
    groups_count = segment_count*G;
    every_group_len = floor(La/groups_count);
    used_A_len = every_group_len * groups_count;
    A_ = A(1:used_A_len);
%     A_i = reshape(A_,N,M,G,every_group_len);
    A_i = reshape(A_,every_group_len,G,M,N);
    A_left = A(used_A_len+1:La);
    
    % calculate the DCT coefficients of A1i,m and A2i,m, and we can obtain the coefficients, as follows:
    DCT_i = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
%                 DCT_i(n,m,g,:) = dct(A_i(n,m,g,:));%dct returns a one dimention matrix from low frequency to high
                DCT_i(:,g,m,n) = dct(A_i(:,g,m,n));
            end
        end
    end
    %Based on the coefficients, we calculate the FDLM features of A1i,m and A2i,m, denoted by F1i,m and F2i,m .
    %We modify the FDLM feature F1i,m and F2i,m to Q1i,m and Q2i,m , defined as follows.
    %delta = 2;
    [Q_feature, K, alpha] = fdlm(DCT_i,delta);
    [feature, K, alpha] = fdlm_ex(DCT_i);
    %embed watermark wm by adding or subtracting/2 to the modified FDLM feature Q1i,m , QF2i,m = Q2i,m .
    Q_F_W = Q_feature;
    R_feature = ones(N,M,1);
    for n=1:N-1
        for m=1:M
%             R_feature(n,m) = abs(Q_feature(n,m,1)-Q_feature(n,m,2));
            R_feature(n,m) = Q_feature(n,m,1)-Q_feature(n,m,2);
            if Q_feature(n,m,1)>Q_feature(n,m,2)
%             if 1 == 1
                if int8(mod(int8(R_feature(n,m,1)/delta),2)) == int8(syn_wm((n-1)*M+m))
                    Q_F_W(n,m,1) = Q_feature(n,m,1) + delta/2;
                else
                    Q_F_W(n,m,1) = Q_feature(n,m,1) - delta/2;
                end
            else
                if int8(mod(int8(R_feature(n,m,1)/delta),2)) == int8(syn_wm((n-1)*M+m))
                    Q_F_W(n,m,2) = Q_feature(n,m,2) - delta/2;
                else
                    Q_F_W(n,m,2) = Q_feature(n,m,2) + delta/2;
                end
            end
        end
    end
    % last frame used count is not correctly M
    for m=1:last_frame_used 
%         R_feature(N,m) = abs(Q_feature(N,m,1)-Q_feature(N,m,2));
        R_feature(N,m) = Q_feature(N,m,1)-Q_feature(N,m,2);
        if Q_feature(N,m,1)>Q_feature(N,m,2)
%         if 1 == 1
            if int8(mod(int8(R_feature(N,m,1)/delta),2)) == int8(syn_wm((N-1)*M+m))
                Q_F_W(N,m,1) = Q_feature(N,m,1) + delta/2;
            else
                Q_F_W(N,m,1) = Q_feature(N,m,1) - delta/2;
            end
        else
            if int8(mod(int8(R_feature(N,m,1)/delta),2)) == int8(syn_wm((N-1)*M+m))
                Q_F_W(N,m,2) = Q_feature(N,m,2) - delta/2;
            else
                Q_F_W(N,m,2) = Q_feature(N,m,2) + delta/2;
            end
        end
    end
    
    %After obtaining QF1i,m and QF2i,m ,the DCT coefficients of A1i,m are modified by
    DCT_modified = DCT_i;
    for n=1:N-1
        for m=1:M
            for g=1:G
                index = (Q_F_W(n,m,g)/feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/feature(n,m,g)));
                index_correct = (Q_F_W(n,m,g)-feature(n,m,g))/log2(2*alpha) + log2(alpha)/log2(2*alpha);
                index1 = (Q_F_W(n,m,g)/feature(n,m,g));
                index2 = 1-(Q_F_W(n,m,g)/feature(n,m,g));
                for k=1:every_group_len
%                     index = (Q_F_W(n,m,g)/Q_feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/Q_feature(n,m,g)));
%                     DCT_modified(k,g,m,n) = sign(DCT_i(k,g,m,n))*(abs(DCT_i(k,g,m,n))^index_correct);
                    DCT_modified(k,g,m,n) = sign(DCT_i(k,g,m,n))*(abs(DCT_i(k,g,m,n))^index1)*(alpha^index2);
                end
            end
        end
    end
    % last frame used count is not correctly M
    for m=1:last_frame_used 
        for g=1:G
            index = (Q_F_W(N,m,g)/feature(N,m,g))*(alpha^(1-Q_F_W(N,m,g)/feature(N,m,g)));
            index_correct = (Q_F_W(n,m,g)-feature(n,m,g))/log2(2*alpha) + log2(alpha)/log2(2*alpha);
            index1 = (Q_F_W(N,m,g)/feature(N,m,g));
            index2 = 1-(Q_F_W(N,m,g)/feature(N,m,g));
            for k=1:every_group_len
%               index = (Q_F_W(n,m,g)/Q_feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/Q_feature(n,m,g)));
%                 DCT_modified(k,g,m,N) = sign(DCT_i(k,g,m,N))*(abs(DCT_i(k,g,m,N))^index_correct);
                DCT_modified(k,g,m,N) = sign(DCT_i(k,g,m,N))*(abs(DCT_i(k,g,m,N))^index1)*(alpha^index2);
            end
        end
    end
    %reconstructure audio by the modified DCT
    A_WM = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
%                 A_WM(n,m,g,:) = idct(DCT_modified(n,m,g,:));%dct returns a one dimention matrix from low frequency to high
                A_WM(:,g,m,n) = idct(DCT_modified(:,g,m,n));
            end
        end
    end
    A_WM_ = reshape(A_WM,used_A_len,1);
    out = [A_WM_;A_left];
    %save the output watermarked audio and calculate the snr
    out = reshape(out,1,[]);%change
    audiowrite(out_audio,out,44100);
%     mp3write(out,fs,out_audio);
    source_mse = reshape(A,1,[]);
    snr = 10*log10((mse(source_mse)/mse(source_mse-out)));
end