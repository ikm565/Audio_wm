function [ snr, N, M, G ] = rfdlm_embed(length_audio,in_audio,out_audio,watermark,delta)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    snr = 0;
    [A,fs]=audioread(in_audio);
    A = A(1:length_audio); %529200
%     %W_LEN = length(watermark);
    %form three segments
    
    %divide A into N equal length frames
    %and Ai into M segments, Ai,m, m = 1, 2,..., M,
    %and form two groups from Ai,m as follows:
    N = 2;% frame count
    M = 3;% every frame embed two synchronization codes and one watermark bits 2+1=3
    G = 2;%every segment is formed into 2 group linked to each other(consecutive group)
    [N,M,G,syn_wm,last_frame_used] = distribute(watermark);
    La = length(A);
    segment_count = N*M;
    groups_count = segment_count*G;
    every_group_len = floor(La/groups_count);
    used_A_len = every_group_len * groups_count;
    A_ = A(1:used_A_len);
    A_i = reshape(A_,N,M,G,every_group_len);
    A_left = A(used_A_len+1:La);
    
    % calculate the DCT coefficients of A1i,m and A2i,m, and we can obtain the coefficients, as follows:
    DCT_i = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
                DCT_i(n,m,g,:) = dct(A_i(n,m,g,:));%dct returns a one dimention matrix from low frequency to high
            end
        end
    end
    %Based on the coefficients, we calculate the FDLM features of A1i,m and A2i,m, denoted by F1i,m and F2i,m .
    %We modify the FDLM feature F1i,m and F2i,m to Q1i,m and Q2i,m , defined as follows.
    %delta = 2;
    [Q_feature, K, alpha] = fdlm(DCT_i,delta);
    %embed watermark wm by adding or subtracting/2 to the modified FDLM feature Q1i,m , QF2i,m = Q2i,m .
    Q_F_W = Q_feature;
    for n=1:N-1
        for m=1:M
            if mod(Q_feature(n,m,1)/delta,2) == syn_wm((n-1)*M+m)
                Q_F_W(n,m,1) = Q_feature(n,m,1) + delta/2;
            else
                Q_F_W(n,m,1) = Q_feature(n,m,1) - delta/2;
            end
        end
    end
    % last frame used count is not correctly M
    for m=1:last_frame_used 
        if mod(Q_feature(N,m,1)/delta,2) == syn_wm((N-1)*M+m)
            Q_F_W(N,m,1) = Q_feature(N,m,1) + delta/2;
        else
            Q_F_W(N,m,1) = Q_feature(N,m,1) - delta/2;
        end
    end
    
    %After obtaining QF1i,m and QF2i,m ,the DCT coefficients of A1i,m are modified by
    DCT_modified = DCT_i;
    for n=1:N-1
        for m=1:M
            for g=1:G
                index = (Q_F_W(n,m,g)/Q_feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/Q_feature(n,m,g)));
                for k=1:K
%                     index = (Q_F_W(n,m,g)/Q_feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/Q_feature(n,m,g)));
                    DCT_modified(n,m,g,k) = sign(DCT_i(n,m,g,k))*(abs(DCT_i(n,m,g,k))^index);
                end
            end
        end
    end
    % last frame used count is not correctly M
    for m=1:last_frame_used 
        for g=1:G
            index = (Q_F_W(N,m,g)/Q_feature(N,m,g))*(alpha^(1-Q_F_W(N,m,g)/Q_feature(N,m,g)));
            for k=1:K
%               index = (Q_F_W(n,m,g)/Q_feature(n,m,g))*(alpha^(1-Q_F_W(n,m,g)/Q_feature(n,m,g)));
                DCT_modified(N,m,g,k) = sign(DCT_i(N,m,g,k))*(abs(DCT_i(N,m,g,k))^index);
            end
        end
    end
    %reconstructure audio by the modified DCT
    A_WM = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
                A_WM(n,m,g,:) = idct(DCT_modified(n,m,g,:));%dct returns a one dimention matrix from low frequency to high
            end
        end
    end
    A_WM = reshape(A_WM,used_A_len,1);
    out = [A_WM;A_left];
    %save the output watermarked audio and calculate the snr
    out = reshape(out,1,[]);%change
    audiowrite(out_audio,out,fs);
    source_mse = reshape(A,1,[]);
    snr = 10*log10((mse(source_mse)/mse(source_mse-out)));
end