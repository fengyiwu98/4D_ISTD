function [B, T] = TR_RPCA(D)
%% initialize parameters
tol = 1e-7;
lambda1 = 0;
lambda2 = 100;
maxiter = 300;
H = 2;

Nway = size(D);
N = ndims(D);
L = ceil(N/2);
sk = zeros(L,1);
RC = nan(maxiter,2);
delta = 1./L*ones(1,L);

epsilon = 1e-3;
beta = 1e-4;
gamma = 1e-4;
beta  = beta * ones(1,L);

%% initialization
B = D;
T = zeros(Nway);
No = zeros(Nway);
E = zeros(Nway);
U = cell(L,1);
C = cell(L,1);

for n = 1:L
    U{n}=B;
    C{n}=zeros(Nway);
    order=[n:N 1:n-1];
    lambda1 =lambda1 + H/sqrt(max([prod(Nway(order(1:L))),prod(Nway(order(L+1:N)))]));
    sk(n) = min([prod(Nway(order(1:L))),prod(Nway(order(L+1:N)))]);
end


%% ADMM algorithm
for iter=1:maxiter
     preT = sum(T(:)>0);  
     
    % update U^(n) (auxiliary variables of low-rank part)   
    u_s = zeros(Nway);
    c_s = zeros(Nway);
    
    for n = 1:L
        order = [n:N 1:n-1];
        m = permute(B - C{n}/beta(n), order);
        M = reshape(m,prod(Nway(order(1:L))),[]);
        [M,sk(n)] = shrink_matrix(M, delta(n)/beta(n), sk(n), epsilon, false);
        m = reshape(M, Nway(order));
        U{n} = ipermute(m, order);
        u_s = u_s + U{n};
        c_s = c_s + C{n};
    end
    
    % update B (low-rank part)
    B = (u_s + c_s/gamma+(D - T - No - E/gamma))./(L+1);

    % update T(sparse part)
    T = shrink_vector((D - B - No - E/gamma),lambda1/gamma);
    
    % update C^(n)
    for n = 1 : L
        C{n}= C{n} + beta(n) * (U{n} - B);
    end
    
    % update E
    E = E + gamma * (B + T + No - D);
    
    %update No
    No = gamma * (D - B - T + E/gamma)/(gamma + 2 * lambda2);
    
    %update gamma and beta
    gamma = min(1.2 * gamma,1e10); 
    beta = min(1.2 * beta,1e10);

    %% Calculate relative error    
    currT = sum(T(:) > 0);
    dY = D - B - T - No;
    errList = norm(dY(:)) / norm(D(:));
    disp(['iter ' num2str(iter)  ...
        ', err=' num2str(errList)...
        ',|T|0 = ' num2str(currT)]);   
    
    if errList < tol %||(preT>0 && currT>0 && preT == currT)
        break;  
    end 

end

end