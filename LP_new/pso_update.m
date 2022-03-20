function [ position,velocity ] = pso_update( swarm,upbound,lowbound,v_max,pbest,gbest,position,velocity )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
w=1;   %惯性权重
c1=2;  %更新时局部最优比重
c2=2;    %更新时全局最优比重
r1=rand(swarm,1);
r2=rand(swarm,1);
r=1;   %位置更新约束因子
gbest1=repmat(gbest,swarm,1);
velocity=w*velocity+c1*r1.*(pbest-position)+c2*r2.*(gbest1-position); %速度更新
for i = 1:swarm
%     w0 = 1.1 - gbest/pbest(i);
%     mr = 1 + gbest/pbest(i);
%     velocity(i)=w0*velocity(i)+mr*(pbest(i)-gbest-2*position(i));
%     velocity(i)=w*velocity(i)+c1*r1.*(pbest(i)-position(i))+c2*r2.*(gbest-position(i));
    if  velocity(i)>v_max
        velocity(i)=v_max;
    elseif velocity(i)<-v_max
           velocity(i)=-v_max;
    end
end
%gbest1 = repmat(gbest,swarm,1);
%velocity=w*velocity+c1*r1.*(pbest-position)+c2*r2.*(gbest1-position); %速度更新
%velocity=w0*velocity+mr*(pbest1-gbest1-2*position);

position=position+r*velocity; %位置更新
for i=1:swarm
        if position(i)<lowbound||position(i)>upbound
           position(i)=rand*(upbound-lowbound)+lowbound;
           velocity(i)=rand*2*v_max-v_max;%位置超过边界时，重新进行初始化
        end
end

end

