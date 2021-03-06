classdef ukfclass < handle
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        x_sigma
        x_next
        y
        
        rho
        g
        T
        var_nu
        var_w
        R
        a
        M
        x
        n
        Q
        x_post
        P_post
        gam
        

    end
    
    methods
        function obj = ukfclass(gIn)
            %UNTITLED11 Construct an instance of this class
            %   Detailed explanation goes here
                if nargin == 0
                    gIn=20000;
                    
%                 else
                    
                end
                k = 2;
                obj.a=(1e5);
                
                obj.gam = gIn;
                obj.y = 0;
                obj.rho=2;
                obj.g=32.2;
                
                obj.T=0.5;
                obj.var_nu=1e4;
                obj.var_w=0;
                
                obj.R=obj.var_nu;
                
                obj.M=1e5;
                obj.x=[3e5 -2e4 0.001]';
%                 obj.x=[2e5 -1e4 0.001]';
                obj.n=length(obj.x);
                obj.Q=zeros(obj.n);
                obj.x_post=obj.x;
                obj.P_post=diag([1e6  4e6 10]);
                
                
                updatefilter(obj,k)
                
                
            end
        
        
        function obj =take_measurement(x,a,M,R)
            obj.y=sqrt(M^2+(x-a)^2)+sqrt(R)*randn;
        end
        
        function obj=generatesigmapoints2(x,P)
            n=length(x);
            S=(chol(n*P));
            for m=1:n
                obj.x_sigma(:,m)=x+S(m,:)';
                obj.x_sigma(:,n+m)=x-S(m,:)';
            end
        end
        function obj =nonlindyn(x_prev,T,gam,g,rho)
%             obj.gam = gam
            obj.x_next(1,1)=x_prev(1)+T*x_prev(2);
            obj.x_next(2,1)=x_prev(2)+...
                T*rho*exp(-x_prev(1)/gam)*x_prev(2)^2*x_prev(3)/2 ...
                -T*g;
            obj.x_next(3,1)=x_prev(3);
        end
        
        function updatefilter(obj, k)
            %%Time update
                xsigma_post=generatesigmapoints2(obj.x_post(:,k-1),obj.P_post(:,:,k-1));
                x_prior=zeros(3,1);
                P_prior=obj.Q;
                for m=1:2*obj.n
                    xx=xsigma_post(:,m);
                    for kk=1:501
                        xx=nonlindyn(xx,obj.T/500,obj.gam,obj.g,obj.rho);
                    end
                    xsigma_prior(:,m)=xx;
                    x_prior=x_prior+xsigma_prior(:,m)/2/obj.n;
                end
                for m=1:2*obj.n
                    error=xsigma_prior(:,m)-x_prior;
                    P_prior=P_prior+error*error'/2/obj.n;
                end
                P_prior=(P_prior+P_prior')/2;
                
                %%
                %System Evolution
                xx=obj.x(:,k-1);
                for kk=1:501
                    xx=nonlindyn(xx,obj.T/500,obj.gam,obj.g,obj.rho);
                end
                obj.x(:,k)=xx;
                %%
            %    Measurement update
                obj.y(k)=take_measurement(obj.x(1,k),obj.a,obj.M,obj.R);
                disp(k)
                
                x_sigma_prior=generatesigmapoints2(x_prior,P_prior);
                y_avg=0;
                for m=1:2*obj.n
                    y_sigma(m)=...
                        take_measurement(x_sigma_prior(1,m),obj.a,obj.M,0);
                    y_avg=y_avg+y_sigma(m)/2/obj.n;
                end
                Py=obj.R;
                Pxy=zeros(obj.n,1);
                for m=1:2*obj.n
                    y_error=y_sigma(m)-y_avg;
                    x_error=x_sigma_prior(:,m)-x_prior;
                    Py=Py+y_error*y_error'/2/obj.n;
                    Pxy=Pxy+x_error*y_error'/2/obj.n;
                end
                Py=(Py+Py')/2;
                %Calculate Kalman Gain
                K=Pxy*Py^-1;
                innov=obj.y(k)-y_avg;
                obj.x_post(:,k)=x_prior+K*innov;
                obj.P_post(:,:,k)=P_prior-K*Py*K';
                obj.P_post(:,:,k)=(obj.P_post(:,:,k)+obj.P_post(:,:,k)')/2;
        end
    end
end

