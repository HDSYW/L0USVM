function [ PredictY , model ] = L2L1n_L1SVC( ValX , Trn , Para )
% Solving [L2-L1-norm Hinge SVC] via linear programming.  
% min   0.5*(wps-wng)'*(wps-wng) + C2*e'*(wps+wng) + C1*e'*xi + 0*b 
%  s.t .   Y.*X*wps - Y.*X*wng + xi + Y*b <= e , 
%           wps >= 0, 
%           wng >= 0, 
%           xi >= 0, 
%           -inf < b < inf. 
% Variables: [wps;wng;xi;b] in R^{n+n+m+1}, 
% wps = max(w,0), wng = -min(w,0), w = wps-wng.
% _______________________________ Input  _______________________________
%      DataTrain.X  -  m x n matrix, expla，natory variables in training data 
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
    C1 = Para.p1;        C2 = Para.p2;     %  kpar = Para.kpar; 

%% Initilization
    tt = tic; 
    
    [ m , n ] = size(X);     IY = diag(Y);  
    En = speye(n);    
    Z2nm1 = zeros(2*n,m+1);    Zm1 = zeros(m+1); 
    EE = [ En , -En ; -En ,  En ]; % #1 in FSUE old
%     EE = speye(2*n); % #2 equal to #1: wps'*wng==0

%     Zn = zeros(n);
%     EE = [ En , Zn ; Zn ,  -En ]; 
    
    H = 0.5 * [ EE, Z2nm1 ; Z2nm1' , Zm1 ]; 
    f = [ C2*ones(2*n,1) ; C1/m*ones(m,1) ; 0 ]; 
    A = - [ IY*X , -IY*X , eye(m) , Y ];
    b = - ones(m,1);
    lb = [ zeros(2*n+m,1) ; -inf ]; 
%     ub = inf * ones(2*n+m+1,1); % can be default
    
    tol = 1e-8; 
    options = optimoptions('quadprog','Display','off');
    
%% Solving LP Problem
    sol = quadprog( H, f, A, b,[],[], lb, [], [], options );    
    tr_time = toc(tt); 
    
    wwxi = sol(1:end-1);        b = sol(end); 
    wwxi(wwxi<tol) = 0; 
    w = wwxi(1:n) - wwxi(n+1:2*n); 
    xi = wwxi(2*n+1:end); 
    
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
    model.n_SV = nnz(xi);
    if Para.plt == 1
        plt.ds = wxb;
        plt.ss1 = plt.ds - 1;
        plt.ss2 = plt.ds + 1;
        model.plt = plt;
    end
    
end


