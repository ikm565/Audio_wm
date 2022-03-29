function [acc_val, wrong_mask] = rfdlm_extract(length_audio,in_audio,watermark,delta,Q_F_W,Q_feature)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    [N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num] = distribute(watermark);
    [A,fs]=audioread(in_audio);
    C = shift(A,length_audio);
    
    [extracted_wm,error,error_mask] = loop_extract2(C,length_audio,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num);
    
    ex_wm = ones(length(watermark),1)-2;
    ex_wm_index = zeros(M-syn_length*2,wat_seg_num);
    for i=1:N
        %distinguish if the code is synchronization
%         flag = 1;
        index = bin2dec(num2str(reshape(extracted_wm((i-1)*M+1:(i-1)*M+syn_length),1,[])));
        index_2 = bin2dec(num2str(reshape(extracted_wm((i-1)*M+syn_length+1:(i-1)*M+syn_length*2),1,[])));
        if index == index_2 && index <= wat_seg_num && index > 0
            ex_wm_index(:,index) = extracted_wm((i-1)*M+syn_length*2+1:(i)*M);
        end
    end
    
    for i=1:wat_seg_num
        ex_wm((i-1)*(M-syn_length*2)+1:(i)*(M-syn_length*2)) = ex_wm_index(:,i);
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