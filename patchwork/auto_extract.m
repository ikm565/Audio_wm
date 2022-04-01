function [acc_val] = auto_extract(length_audio,in_audio,watermark,delta,Q_F_W,Q_feature)
    %coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
        [N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num] = distribute(watermark);
        [A,fs]=audioread(in_audio);
        C = shift(A,length_audio);
        
        [extracted_wm,acc_val,error_mask] = loop_extract3(C,length_audio,watermark,delta,N,M,G,syn_wm,last_frame_used,syn_length,wat_seg_num);
        fprintf('%d ', acc_val);
        fprintf('\n');
    end