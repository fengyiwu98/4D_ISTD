function [B, T] = TT_RPCA(D)
%% initialize parameters
tol = 1e-7;      
lambda1 = 0;
lambda2 = 100;
max_iter = 300; 
IL = 1;
H = 2;

Nway = size(D); 
alpha = weightTC(Nway);
N = length(Nway);   
dimL = zeros(1,N-1);
dimR = zeros(1,N-1);

beta = 1e-4;
gamma = 1e-4;
beta  = beta * ones(1,N-1);

%% initialization
B = D;
T = zeros(Nway);
No = zeros(Nway);
E = zeros(Nway);
U = cell(1,N-1);
C = cell(1,N-1);

for m = 1:N-1
    C{m} = zeros(Nway); 
    dimL(m) = IL*Nway(m);
    dimR(m) = prod(Nway)/dimL(m);
    lambda1 = lambda1 + H/(sqrt(max(dimL(m),dimR(m))));
    IL = dimL(m);
end


%% ADMM algorithm
for iter = 1 : max_iter
    preT = sum(T(:) > 0);
          
    % update U^(n) (auxiliary variables of low-rank part)
    u_s = zeros(Nway);
    c_s = zeros(Nway);
    
    for n = 1:N-1
        M = SVT(reshape(B - C{n}/beta(n), [dimL(n) dimR(n)]), alpha(n)./beta(n) );
        U{n} = reshape(M, Nway);
        u_s = u_s + U{n}*beta(n);
        c_s = c_s + C{n};
    end
      
    % update B (low-rank part)
    B = (u_s + c_s + gamma * (D - T - No + E/gamma)) / ( gamma + sum(beta(:)));
    
    % update T(sparse part) 
	T = soft_shrink(D - B - No + E/gamma, lambda1/gamma);
    
    % update C^(n)
    for n = 1: N-1
        C{n} = C{n} + beta(n) * (U{n} - B);
    end
    
    % update E 
    E = E + gamma * (D - B - T - No);
    
    %update No
    No = gamma * (D - B - T + E/gamma)/(gamma + 2 * lambda2);
    
    %update gamma and beta    
    gamma = min(1.2 * gamma,1e10);  
    beta = min(1.2 * beta,1e10);

    %% Calculate relative error
    currT = sum(T(:) > 0);
    dY = D - B - T - No;
    errList = norm(dY(:)) / norm(D(:));
	disp(['iter ' num2str(iter) ...
        ', err=' num2str(errList)...
        ',|T|0 = ' num2str(currT)]); 

    if  errList < tol %|| (preT>0 && currT>0 && preT == currT)
        break;
    end
 
end

end