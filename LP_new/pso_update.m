function [ position,velocity ] = pso_update( swarm,upbound,lowbound,v_max,pbest,gbest,position,velocity )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
w=1;   %����Ȩ��
c1=2;  %����ʱ�ֲ����ű���
c2=2;    %����ʱȫ�����ű���
r1=rand(swarm,1);
r2=rand(swarm,1);
r=1;   %λ�ø���Լ������
gbest1=repmat(gbest,swarm,1);
velocity=w*velocity+c1*r1.*(pbest-position)+c2*r2.*(gbest1-position); %�ٶȸ���
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
%velocity=w*velocity+c1*r1.*(pbest-position)+c2*r2.*(gbest1-position); %�ٶȸ���
%velocity=w0*velocity+mr*(pbest1-gbest1-2*position);

position=position+r*velocity; %λ�ø���
for i=1:swarm
        if position(i)<lowbound||position(i)>upbound
           position(i)=rand*(upbound-lowbound)+lowbound;
           velocity(i)=rand*2*v_max-v_max;%λ�ó����߽�ʱ�����½��г�ʼ��
        end
end

end

