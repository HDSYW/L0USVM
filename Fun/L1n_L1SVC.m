function [ PredictY , model ] = L1n_L1SVC( ValX , Trn , Para )
% Solving [L1-norm Hinge SVC] via linear programming.  
% min   e'*(wps+wng) + C*e'*xi + 0*b 
%  s.t .   Y.*X*wps - Y.*X*wng + xi + Y*b <= e , 
%           wps >= 0, 
%           wng >= 0, 
%           xi >= 0, 
%           -inf < b < inf. 
% Variables: [wps;wng;xi;b] in R^{n+n+m+1},  
% wps = max(w,0), wng = -min(w,0), w = wps-wng.
% _______________________________ Input  _______________________________
%      DataTrain.X  -  m x n matrix, explanatory variables in training data 
%      DataTrain.Y  -  m x 1 vector, response variables in training data 
%      ValX   -  mv x n matrix, explanatory variables in validation data 
%      Para.p1  -  the emperical risk parameter C 
% ______________________________ Output  ______________________________
%     PredictY  -  mt x 1 vector, predicted response variables for TestX 
%     model  -  model related info: alpha, b, nSV, time, etc.
% 
% Written by Lingwei Huang, lateset update: 2021.12.10. 

%% Input 
    X = Trn.X;        Y = Trn.Y;        clear Trn
%     kpar = Para.kpar; 
    C1 = Para.p1; 

%% Initilization
    tt = tic; 
    
    [ m , n ] = size(X);     
    f = [ ones(2*n,1) ; C1/m*ones(m,1) ; 0 ]; 
    A = - [ Y.*X , -Y.*X , speye(m) , Y ];
    b = - ones(m,1);
    lb = [ zeros(2*n+m,1) ; -inf ]; 
    options = optimoptions('linprog','Display','off');
    
%% Solving LP Problem
    [ sol , ~,~,~, lambda ] = linprog( f, A, b,[],[], lb, [], options );
    % [ sol , ~,~,~, lambda ] = linprog( f, A, b,[],[], lb, [], [], options );
    tr_time = toc(tt); 
    
    if isempty(sol)
        w = zeros(n,1);     b = 0;
    else
        w = sol(1:n) - sol(n+1:n+n);        b = sol(end);
    end
    
    alpha = lambda.ineqlin;
    spsN = nnz(~w);           % Sparse Number, # of useless features
    spsR = spsN / n * 100; % Sparse Ratio, % of useless features
    
%% Prediction & Output   
    wxb = ValX * w + b;
    PredictY = sign( wxb + eps ); % realmin
    
    model.w = w; 
%     model.b = b; 
    model.w_ind = w~=0;
    model.spsN = spsN;
    model.nFea = n; 
    model.spsR = spsR;
    
    model.tr_time = tr_time;
    model.n_SV = nnz(alpha);
    if Para.plt == 1
        plt.ds = wxb;
        plt.ss1 = plt.ds - 1;
        plt.ss2 = plt.ds + 1;
        model.plt = plt;
    end
    
end


