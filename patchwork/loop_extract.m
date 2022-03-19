function [extracted_wm] = loop_extract(A,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
%     [N,M,G,syn_wm,last_frame_used] = distribute(watermark);
    La = length(A);
    segment_count = N*M;
    groups_count = segment_count*G;
    every_group_len = floor(La/groups_count);
    used_A_len = every_group_len * groups_count;
    A_ = A(1:used_A_len);
    A_i = reshape(A_,every_group_len,G,M,N);
    A_left = A(used_A_len+1:La);
    DCT_i = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
                DCT_i(:,g,m,n) = dct(A_i(:,g,m,n));%dct returns a one dimention matrix from low frequency to high
            end
        end
    end
    [feature, K, alpha] = fdlm_ex(DCT_i);
%     feature = Q_F_W;
    R_feature = ones(N,M,1);
    extracted_wm = ones(length(syn_wm),1);
    for n=1:N
        for m=1:M
%             R_feature(n,m) = abs(feature(n,m,1)-feature(n,m,2));
            R_feature(n,m) = feature(n,m,1)-feature(n,m,2);
            extracted_wm((n-1)*M+m) = mod(floor(R_feature(n,m)/delta),2);
        end
    end
    %get watermark based on synchronization code
    error = biterr(syn_wm, extracted_wm);
    error_mask = xor(syn_wm, extracted_wm);
    
    window_size = floor(length(A_)/(100*N));
    for i=1:syn_length
        if int8(extracted_wm(i)) ~= int8(extracted_wm(i+syn_length))
            A = [A(window_size:-1);ones(window_size,1)];
            extracted_wm = loop_extract(A,watermark,delta,N,M,G,syn_wm,last_frame_used);
        end
    end
end