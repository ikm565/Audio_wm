function [ syn_extract ] = syn_extraction( PA,Q,syn_len )
%SYN_EXTRACTION Summary of this function goes here
%   Detailed explanation goes here
% syn_len = 16;
n = length(PA);
syn_seg_len = n/syn_len;
u=1;
for k = 1:syn_len
       CPA(k,:) = PA((k-1)*syn_seg_len+1:k*syn_seg_len);
       x=mod( CPA(k,u),Q);
       if x<3*Q/4 && x>=Q/4
           syn_extract(k) = 0;
       else
           syn_extract(k) = 1;
        end
end

end

