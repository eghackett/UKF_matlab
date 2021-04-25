function x_next=nonlindyn(x_prev,T,gam,g,rho)

x_next(1,1)=x_prev(1)+T*x_prev(2);
x_next(2,1)=x_prev(2)+...
    T*rho*exp(-x_prev(1)/gam)*x_prev(2)^2*x_prev(3)/2 ...
    -T*g;
x_next(3,1)=x_prev(3);

