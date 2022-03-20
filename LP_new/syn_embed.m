function [ PA_syn] = syn_embed( PA,syn_code,syn_len,Q )
%将同步码采用均值修改的方法嵌入到PA
% input： 用于嵌入的音频分段PA，混沌映射生成的同步码,同步码长度
%output： 嵌入同步码的音频分段，表示为PA_len
[m,n]=size(PA);
syn_seg_len = n/syn_len;
u=1;
k=floor(m/4);
PA_syn=PA;
for i=1:4
    for j = 1:syn_len
           CPA(j,:) = PA((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len);
%            mean_CPA(k) = sum( CPA(k,:))/syn_seg_len;
           if syn_code(j)==1
               CPA(j,u) = round(CPA(j,u)/Q)*Q;
           else 
               CPA(j,u) = floor(CPA(j,u)/Q)*Q+Q/2;
           end
%            x=mod( CPA(k,u),Q);
%            if x<3*Q/4 && x>=Q/4
%                syn_extract(k) = 0;
%            else
%                syn_extract(k) = 1;
           PA_syn((i-1)*k+1,(j-1)*syn_seg_len+1:j*syn_seg_len)=CPA(j,:);
    end
end
% for i=1:m
%     for j=1:syn_len
%         S(j,:) = PA(i,(j-1)*syn_seg_len+1:j*syn_seg_len);    
%         if syn_code(j)==1
%             S(j,1) = round(S(j,1)/Q)*Q;
%         else 
%             S(j,1) = floor(S(j,1)/Q)*Q+Q/2;
%         end
%         PA_syn(i,(j-1)*syn_seg_len+1:j*syn_seg_len) = S(j,:);
%     end
% end

end

