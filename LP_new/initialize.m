function [position,velocity] = initialize( swarm,upbound,lowbound,v_max )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
position=rand(swarm,1)*(upbound-lowbound)+lowbound;
velocity=rand(swarm,1)*2*v_max-v_max;

end

