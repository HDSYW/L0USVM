function [PredictY, model] = USVM(ValX, Trn, Para)
    % solving [VladimirVapnik Universum SVC]
    % primal:
        % min 0.5*norm(w,2)^2 + C*em*xi + Cu*e2u*eta
        %     s.t. y*(w'*x) >= 1 - xi_i     xi_i >= 0 , i = 1,...,m
        %          yu*(w'*xu) <= eta_i      eta_i>= 0 , i = m+1,...,m+2n

    % Dual:
        % min 0.5*alph'*EY*K*EY*alph - rho'*alph
        %  s.t.  0<alph<C,              i=1:m,
        %        0<alph<Cu,             i=m+1:m+2n,
        %        rho=-epsilon,          i=1:m, 
        %        rho=0,                 i=m+1:m+2n, 
    % _______________________________ Input  _______________________________
    %   Trn.X  -  m x n matrix, explanatory variables in training data 
    %   Trn.Y  -  m x 1 vector, response variables in training data 
    %   Trn.Ux  - mU x n matrix, Universum data
    %   Trn.Uy  - mU x1 vector, Universum label 
    %   ValX   -  mt x n matrix, explanatory variables in Validation data 
    %   Para.p1  -  the emperical risk parameter C 
    %   Para.p2  -  the Universum parameter Cu 
    %   Para.kpar  -  kernel para, include type and para value of kernel
    % ______________________________ Output  ______________________________
    %   PredictY  -  mt x 1 vector, predicted response variables for TestX 
    %   model  -  model related info: alpha, b, nSV, time, etc.
    %   
    %   Written by Junshan Yin, lastset update: 2023.3.22
    %   Copyright 2023 Junshan Yin
 
        
        %% Input 
            X = Trn.X;              Y = Trn.Y;       % ori data
            Ux = Trn.Ux;            Uy = Trn.Uy;     % Uni data 
            C = Para.p1;            Cu = Para.p2;     
            epsilon = Para.p3 ;           rho_u = - epsilon ;
            kpar = Para.kpar;
            [mU,~] = size(Ux);
            X_and_Xu = sparse([X;Ux]);   
            Y_and_Yu = [ Y ; Uy ]; 
            
        %% Initilization 
            tt = tic; 
            
            [m,n] = size(X); 
            em = ones(m,1);      emU = ones(mU,1);      C_and_Cu = [C*em; Cu*emU];  
            rho_mU = rho_u * ones(mU,1);  zeros_m_mU = zeros(m + mU,1);
            EY = diag(Y_and_Yu);
            
            eps1 = 1e-6;            
            options = optimoptions('quadprog','Display','off');
            clear Trn X Ux Uy
            
        %% Obtain alpha 
            K = KerF( X_and_Xu , kpar , X_and_Xu );
            H = EY * K * EY;
            f = [-em; rho_mU];
            lb = zeros_m_mU ;
            ub = [ C*em ; Cu*emU];
            ALPH = quadprog(H, f, [], [], [], [], lb, ub, [], options);
            
            % Setting alpha
            id_0 = ALPH < eps1;               ALPH(id_0) = 0;
            id_C = C_and_Cu - ALPH < eps1;    ALPH(id_C) = C_and_Cu(id_C); 
            
            % Clear 
            clear K H f Aeq beq lb ub 

            % find id of ALPH

            tr_time = toc(tt);

        %% Prediction and output
            wx = KerF(ValX, kpar, X_and_Xu) * EY * ALPH;
            PredictY = sign(wx);
            

            w = X_and_Xu' * EY * ALPH;
           
            model.w = w;
            idw0 = model.w;                    
            idw0 = (abs(idw0)<=1e-14);
            
            model.w_ind = ~idw0;               % id of useful feature
            model.spsN = nnz(idw0);            % Sparse Number, useless feas #
            model.nFea = n;
            model.spsR = model.spsN / n *100;  % Sparse Ratio, useless feas %
            
            model.tr_time = tr_time;
            model.n_SV = nnz(ALPH);


end