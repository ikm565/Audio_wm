function [acc_val, wrong_mask] = rfdlm_extract(length_audio,in_audio,watermark,delta)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    [N,M,G,syn_wm,last_frame_used] = distribute(watermark);
    [A,fs]=audioread(in_audio);
    A = A(1:length_audio); %529200
    La = length(A);
    segment_count = N*M;
    groups_count = segment_count*G;
    every_group_len = floor(La/groups_count);
    used_A_len = every_group_len * groups_count;
    A_ = A(1:used_A_len);
    A_i = reshape(A_,N,M,G,every_group_len);
    A_left = A(used_A_len+1:La);
    DCT_i = A_i;
    for n=1:N
        for m=1:M
            for g=1:G
                DCT_i(n,m,g,:) = dct(A_i(n,m,g,:));%dct returns a one dimention matrix from low frequency to high
            end
        end
    end
    [feature, K, alpha] = fdlm_ex(DCT_i);
    R_feature = ones(N,M,1);
    extracted_wm = syn_wm;
    for n=1:N
        for m=1:M
            R_feature(n,m) = abs(feature(n,m,1)-feature(n,m,2));
            extracted_wm((n-1)*M+m) = mod(floor(R_feature(n,m)/delta),2);
        end
    end
    %get watermark based on synchronization code
    ex_wm = watermark;
    for i=1:floor(length(syn_wm)/3)
        if extracted_wm((i-1)*3+1)== extracted_wm((i-1)*3+2)
            ex_wm(i) = extracted_wm((i-1)*3+3);
        else
            ex_wm(i) = 0;
        end
    end
    acc_val = 1 - sum(xor(watermark,ex_wm))/(length(ex_wm));
    wrong_mask = ex_wm;
    for i=1:length(ex_wm)
        if xor(watermark(i),ex_wm(i))==0
            wrong_mask(i) = 1;
        else
            wrong_mask(i) = 0;
        end
    end
end