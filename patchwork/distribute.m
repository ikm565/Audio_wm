function [N,M,G,syn_wm_all,last_frame_used,syn_length,wat_seg_num] = distribute(watermark)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    wat_num= 1;
    wat_seg_num = 4;
    syn_length = 6; %log2(wat_seg_num)
%     copy_wm = ones(length(watermark)*wat_num)
%     for i=1:wat_num-1
%         copy_wm = [copy_wm,watermark];
%     end
    how_many_seg = wat_seg_num*wat_num;
    W_LEN = length(watermark)*wat_num;
    M = floor(W_LEN/how_many_seg) + syn_length*2;
    
    N = 50;% frame count
%     M = 27;% every frame embed two synchronization codes and one watermark bits 2+1=3 
    %which means M1==1
    G = 2;%every segment is formed into 2 group linked to each other(consecutive group)
%     W_LEN = length(watermark);
    %(M-2)*N = W_LEN;
    N = ceil(W_LEN/(M-syn_length*2));
    last_frame_used = M - (N*(M-syn_length*2) - W_LEN);
    
    syn_code = ones(wat_seg_num*syn_length,1);
    for i=1:wat_seg_num
        code = dec2bin(i,syn_length) - '0';
        for j=1:syn_length
            syn_code((i-1)*syn_length+j) = code(j);
        end
    end
    embed_len = length(watermark) + wat_seg_num*syn_length*2;
    syn_wm = ones(embed_len,1);
  
    for i=1:wat_seg_num
        syn_wm((i-1)*M+1:(i)*M) = [syn_code((i-1)*syn_length+1:i*syn_length);syn_code((i-1)*syn_length+1:i*syn_length);watermark((i-1)*(M-syn_length*2)+1:i*(M-syn_length*2))];
    end
    
    syn_wm_all = syn_wm;
    for i=1:wat_num-1
        syn_wm_all = [syn_wm_all;syn_wm];
    end
end