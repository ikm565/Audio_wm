function [N,M,G,syn_wm,last_frame_used] = distribute(watermark)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    N = 50;% frame count
    M = 22;% every frame embed two synchronization codes and one watermark bits 2+1=3
    G = 2;%every segment is formed into 2 group linked to each other(consecutive group)
    W_LEN = length(watermark);
    %(M-2)*N = W_LEN;
    N = ceil(W_LEN/(M-2));
    last_frame_used = M - (N*(M-2) - W_LEN);
    embed_len = 3*W_LEN;
    syn_wm = ones(embed_len,1);
    for i=1:W_LEN
        syn_wm((i-1)*3+1) = 0;
        syn_wm((i-1)*3+2) = 0;
        syn_wm((i-1)*3+3) = watermark(i);
    end
end