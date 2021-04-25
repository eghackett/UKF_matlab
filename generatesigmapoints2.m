function x_sigma=generatesigmapoints2(x,P)
n=length(x);
% S=(chol(n*P));
% for m=1:n
%     x_sigma(:,m)=x+S(m,:)';
%     x_sigma(:,n+m)=x-S(m,:)';
% end

try
    S=(chol(n*P));
    mtest = n*P
catch
    A = n*P;
%     tic,Uj = nearestSPD(n*P);toc
    A(isnan(A))=1
    eigs(A')
    S=(chol(A));

end

for m=1:n
    x_sigma(:,m)=x+S(m,:)'
    x_sigma(:,n+m)=x-S(m,:)'
end