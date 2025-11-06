function  w_hat = w_hatByWorkSet(rho,Ux, X, Y, betaV, deltaV, gammaV, tauV, u1, u2, u3,u4, WorkSetRatio)
    % Copyright: Junshan Yin
    % LastUpdate: 2023-9-14
    
    %% Setting Work Set
    n_w_hat = length(tauV);
    n_tauV = length(tauV(1:end-1));
    WorkSetFeaNum = floor(WorkSetRatio * n_tauV);
    zero_index = find(tauV(1:end-1) == 0);
    non_zero_index = find(tauV(1:end-1) ~= 0);
    non_zero_element = tauV(tauV(1:end-1) ~= 0);
    
    if n_tauV >= 1000
        matrix = [non_zero_index,abs(non_zero_element)];
        sorted_matrix = sortrows(matrix, -2);
        non_zero_index = sorted_matrix(:,1);
        
        if WorkSetFeaNum <= length(non_zero_index)
            non_zero_index = non_zero_index(1:WorkSetFeaNum);
            
        elseif isempty(non_zero_index)
            non_zero_index = randperm(n_tauV, WorkSetFeaNum);
            
        else
           non_zero_index = [non_zero_index; zero_index(1:WorkSetFeaNum-length(non_zero_index))];
        end
        
    else
        if isempty(non_zero_index)
            non_zero_index = randperm(n_tauV, WorkSetFeaNum);
        end
    end
    
    % Crop tauV and u4
    tauV = [tauV(non_zero_index);tauV(end)];
    u4 = [u4(non_zero_index);u4(end)];
    
    % Crop data
    X = X(:,non_zero_index);
    Ux = Ux(:,non_zero_index);
   
    [m, n] = size(X);   [mU,~] = size(Ux);
    em = ones(m,1);     emU = ones(mU,1);      enn = eye(n);
    X_hat = [X,em];     Xu_hat = [Ux,emU];
        

    %% Calculate w_hat
    H1 = [(rho+1)*enn, zeros(n,1);...
        zeros(1,n),    rho     ];
    H = H1 + rho*(X_hat'*X_hat + 2*(Xu_hat'*Xu_hat));
    h = rho*(X_hat'*Y'*(betaV - em + u1) + Xu_hat'*(deltaV - gammaV + u3 - u2) - (tauV + u4));
    w_hat = - H\h;
    
    %% recover w_hat
    base_matrix = zeros(n_w_hat,1);

    for i = 1:length(non_zero_index)
        base_matrix(non_zero_index(i)) = w_hat(i);
    end
    base_matrix(end) = w_hat(end);
    w_hat = base_matrix;
end