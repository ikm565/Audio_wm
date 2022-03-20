function [fx] = pwnlcm_map(r,x)
    if x<=r && x>=0
        fx = x/r;
    elseif x<=0.5 && x>=r
            fx = (x-r)/(0.5-r);
    elseif x<=1 && x>=0.5
                fx = pwnlcm_map(r,1-x);
    end
 end


