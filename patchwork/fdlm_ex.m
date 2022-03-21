function [F_A, K, alpha] = fdlm_ex(DCT_i)
%coded by Chang Liu(James Ruslin:hichangliu@mail.ustc.edu.cn) in 5/3/2022
    size_DCT = size(DCT_i); %size_DCT=[N,M,G,LEN]
    N = size_DCT(4);
    M = size_DCT(3);
    G = size_DCT(2);
    K = floor(3/4*size_DCT(1)); % Inspired by this, we set K = 3L/4 in Eq. (6).
%     DCT_used = ones(N,M,G,K);
    F_A = ones(N,M,G,1);
    alpha = 12; %we set α = 12 in this paper
%     feature_k = ones(K,1);
    for n=1:N
        for m=1:M
            for g=1:G
%                 DCT_used(n,m,g,:) = DCT_i(n,m,g,1:K);
                for k=1:K
%                     feature_k(k)=log2(abs(DCT_i(k,g,m,n))/alpha);
                    if k==1
                        plus_num = log2(abs(DCT_i(k,g,m,n))/alpha);
                        if isinf(plus_num)
                            now_feature = 0;
                        else
                            now_feature = plus_num;
                        end
                    else
                        plus_num = log2(abs(DCT_i(k,g,m,n))/alpha);
                        if isinf(plus_num)
                            now_feature = now_feature + 0;
                        else
                            now_feature = now_feature + plus_num;
                        end
                    end
                end
                F_A(n,m,g,1) = abs(now_feature)/K;
            end
        end
    end
end 