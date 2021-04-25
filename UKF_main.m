clc;clear;close all;
% Unscented Kalman Filter,
rho=2;
g=32.2;
gam=20000;
T=0.5;
var_nu=1e4;
var_w=0;
R=var_nu;
a=1e5;
M=1e5;
x=[3e5 -2e4 0.001]';
n=length(x);
Q=zeros(n);
x_post=x;
P_post=diag([1e6  4e6 10]);
y=0;
%%
for k=2:60
    %%Time update
    xsigma_post=generatesigmapoints2(x_post(:,k-1),P_post(:,:,k-1));
    x_prior=zeros(3,1);
    P_prior=Q;
    for m=1:2*n
        xx=xsigma_post(:,m);
        for kk=1:501
            xx=nonlindyn(xx,T/500,gam,g,rho);
        end
        xsigma_prior(:,m)=xx;
        x_prior=x_prior+xsigma_prior(:,m)/2/n;
    end
    for m=1:2*n
        error=xsigma_prior(:,m)-x_prior;
        P_prior=P_prior+error*error'/2/n;
    end
    P_prior=(P_prior+P_prior')/2;
    %%
    %System Evolution
    xx=x(:,k-1);
    for kk=1:501
        xx=nonlindyn(xx,T/500,gam,g,rho);
    end
    x(:,k)=xx;
    %%
%    Measurement update
    y(k)=take_measurement(x(1,k),a,M,R);
    x_sigma_prior=generatesigmapoints2(x_prior,P_prior);
    y_avg=0;
    for m=1:2*n
        y_sigma(m)=...
            take_measurement(x_sigma_prior(1,m),a,M,0);
        y_avg=y_avg+y_sigma(m)/2/n;
    end
    Py=R;
    Pxy=zeros(n,1);
    for m=1:2*n
        y_error=y_sigma(m)-y_avg;
        x_error=x_sigma_prior(:,m)-x_prior;
        Py=Py+y_error*y_error'/2/n;
        Pxy=Pxy+x_error*y_error'/2/n;
    end
    Py=(Py+Py')/2;
    %Calculate Kalman Gain
    K=Pxy*Py^-1;
    innov=y(k)-y_avg;
    x_post(:,k)=x_prior+K*innov;
    P_post(:,:,k)=P_prior-K*Py*K';
    P_post(:,:,k)=(P_post(:,:,k)+P_post(:,:,k)')/2;
end
%%
timevec=(1:k)*T;
figure;
subplot(3,1,1);plot(timevec,x(1,:),timevec,x_post(1,:),'.');grid on;
legend('Position (true)','Position (estimated)');
subplot(3,1,2);plot(timevec,x(2,:),timevec,x_post(2,:),'.');grid on;
legend('Speed (true)','Speed (estimated)');
subplot(3,1,3);plot(timevec,x(3,:),timevec,x_post(3,:),'.');grid on;
legend('Balistic Parameter (true)','Balistic Parameter (estimated)');
xlabel('Time(s)');
figure;
subplot(3,1,1);plot(timevec,x(1,:)-x_post(1,:));grid on;
legend('Position Error');
subplot(3,1,2);plot(timevec,x(2,:)-x_post(2,:));grid on;
legend('Speed Error');
subplot(3,1,3);plot(timevec,x(3,:)-x_post(3,:));grid on;
legend('Balistic Parameter Error');
xlabel('Time(s)');

