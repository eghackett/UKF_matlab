function x_sigma=generatesigmapoints2(x,P)
n=length(x);
S=(chol(n*P));
for m=1:n
    x_sigma(:,m)=x+S(m,:)';
    x_sigma(:,n+m)=x-S(m,:)';
end
