function [extracted_wm,error,error_mask] = loop_extract(A,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
%     [N,M,G,syn_wm,last_frame_used] = distribute(watermark);
    La = length(A);
    segment_count = N*M;
    groups_count = segment_count*G;
    every_group_len = floor(La/groups_count);
    used_A_len = every_group_len * groups_count;
    flag = 1;
    while flag
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
        window_size = 110736;
        first_syn = int8(bin2dec(num2str(reshape(extracted_wm(1:syn_length),1,[]))));
        second_syn = int8(bin2dec(num2str(reshape(extracted_wm(syn_length+1:syn_length*2),1,[]))));
        loop_size = flag*window_size;
        if first_syn == second_syn
            fprintf('%d ', loop_size);
            fprintf('%d ', [first_syn,second_syn]);
            fprintf('\n');
        end
        if first_syn ~= second_syn || first_syn > wat_seg_num || first_syn <= 0
            A = [A(window_size+1:length(A));A(1:window_size)];
            flag = flag + 1;
        else
            flag = 0;
        end
%        if first_syn ~= second_syn || first_syn > wat_seg_num || first_syn <= 0
%            A = [A(window_size+1:length(A));A(1:window_size)];
%            [extracted_wm,error,error_mask] = loop_extract(A,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num);
%        end
    end
%     for i=1:syn_length
%         if int8(extracted_wm(i)) ~= int8(extracted_wm(i+syn_length)) || bin2dec()
% %             A = [A(window_size+1:length(A));zeros(window_size,1)+0.0025];
%             A = [A(window_size+1:length(A));A(1:window_size)];
%             extracted_wm = loop_extract(A,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length);
%         end
%     end
end