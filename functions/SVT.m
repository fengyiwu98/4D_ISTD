% function [ X ] = SVT( A, tau)
%     [U0,Sigma0,V0] = svd( full(A), 'econ' );  %%%%%%%%mex file SVD
%     Sigma0 = diag(Sigma0);
%     S      = soft(Sigma0, tau);
%     r      = sum( S>1 );
%     U      = U0(:,1:r);
%     V      = V0(:,1:r);
%     X      = U*diag(S(1:r))*V';
% e
function [ X ] = SVT( A, tau)

    [U,S,V]=svd(A,'econ');
    s=diag(S);
    idx=find(s>tau,1,'last');
    X=U(:,1:idx)*diag(s(1:idx)-tau)*V(:,1:idx)';
end