function  [PredictY, model]= L0USVM(ValX, Data, Para)
    % Copyrigth Junshan Yin; 
    % LastUpdate: 2023.9.6
     
    %% ------------------ 1.Preparation section --------------------
    X = Data.X;         Y = diag(Data.Y);     Ux = Data.Ux;       Uy = Data.Uy;
    [m, n] = size(X);    [mU,~] = size(Ux);
    em = ones(m,1);     emU = ones(mU,1);   
    X_hat = [X,em];     Xu_hat = [Ux,emU];
    
    if isfield(Para,'rho');    rho = Para.rho;              else; rho = 2;        end
    if isfield(Para,'itmax');  itmax = Para.itmax;          else; itmax = 2;      end % 最大的迭代次数
    if isfield(Para,'w_svm');  w = Para.w_svm;              else; w = ones(n,1);  end % 最大的迭代次数
    if isfield(Para,'eta');    eta = Para.eta;              else; eta = 10;       end % 学习参数
    if isfield(Para,'WrokSet');WrokSet = Para.WrokSet;      else; WrokSet = "OFF";end % 学习参数
      
    if  WrokSet ~= "ON",enn = eye(n);end
    
    % ---------------------------------------------------------------------
    C       = Para.p1;
    Cu      = Para.p2;
    lamda   = Para.p3;
    epsilon = Para.p4;
    
    eps_pri = 1e-5;
    eps_dual = 1e-5;
    
    b = 1;
    w_hat = [w;b];
    u1 = zeros(m,1);
    u2 = zeros(mU,1);
    u3 = zeros(mU,1);
    u4 = zeros(n+1,1);
    tau0 = ones(n+1,1);
    
    [rho_1,rho_2,rho_3,rho_4] = deal(rho);
    
    
    iter_betaV = ones(m,itmax);     iter_gammaV = ones(mU,itmax);   
    iter_deltaV = ones(mU,itmax);   iter_tauV = ones(n+1,itmax);
    iter_obj = ones(itmax,1);       iter_r_norm = ones(itmax,1);
    iter_s_norm = ones(itmax,1);    iter_r = ones(m+2*mU+n+1,1);
    iter_s = ones(n+1,1);           iter_rho = nan(itmax,1);
    iter_rho_1 = ones(itmax,1);     iter_rho_2 = ones(itmax,1);
    iter_rho_3 = ones(itmax,1);     iter_rho_4 = ones(itmax,1);
    
    tt = tic;
    %% --------------------- 2.ADMM Sover --------------------------
    for it = 1: itmax
        
       %% Sttp 1 
        % update beta
        betaTh = C/rho_1;
        betaV = zeros(m,1);
        v = em - Y*X_hat*w_hat - u1;
        
        betaV(v<0) = v(v<0);
        v_betaTh = v - betaTh;
        betaV(v>betaTh) = v_betaTh(v>betaTh);
        
        iter_betaV(:,it) = betaV;
        
        iter_rho_1(it) = rho_1;
        
        % update gamma
        gammaTh = Cu/rho_2;
        gammaV = zeros(mU,1);
        q = Xu_hat*w_hat - epsilon*emU - u2;
        
        gammaV(q<0) = q(q<0);
        q_gammaTh = q - gammaTh;
        gammaV(q>gammaTh) = q_gammaTh(q>gammaTh);
        
        iter_gammaV(:,it) = gammaV;
        
        iter_rho_2(it) = rho_2;
        
        % update gamma
        deltaTh = Cu/rho_3;
        deltaV = zeros(mU,1);
        s = -Xu_hat*w_hat - epsilon*emU - u3;
        
        deltaV(s<0) = s(s<0);
        s_deltaTh = s - deltaTh;
        deltaV(q>deltaTh) = s_deltaTh(q>deltaTh);
        
        iter_deltaV(:,it) = deltaV;
        
        iter_rho_3(it) = rho_3;
        
        % update tau
        tauTh = sqrt((2*lamda)/rho_4);
        tauV = zeros(n+1,1);
        t = w_hat - u4;
        
        tauV(abs(t)>tauTh) = t(abs(t)>tauTh);
        tauV(end) = t(end);
        iter_tauV(:,it) = tauV;
        
        
        if Para.L0USVM.UpdateRho == "ON"
            if nnz(tauV) > nnz(tau0)
                %             rho = nnz(tauV)/nnz(tau0) * rho;
                rho = nnz(tau0)/nnz(tauV) * rho;
                [rho_1,rho_2,rho_3,rho_4] = deal(rho);
                iter_rho(it) = rho;
            end
            tau0 = tauV;
        end
        
        model.iter_nnz_tau(it) = nnz(tauV(1:end-1));
        iter_rho_4(it) = rho_4;
        
       %% Step 2
        % update w
        w_hat0 = w_hat;
        if  WrokSet == "ON"
            WorkSetRatio = Para.L0USVM.WorkSetRatio;
            w_hat = w_hatByWorkSet(rho, Ux, X, Y, betaV, deltaV, gammaV, tauV, u1, u2, u3,u4, WorkSetRatio);
        
        else
            H1 = [(rho+1)*enn, zeros(n,1);...
                zeros(1,n),    rho     ];
            H = H1 + rho*(X_hat'*X_hat + 2*(Xu_hat'*Xu_hat));
            h = rho*(X_hat'*Y'*(betaV - em + u1) + Xu_hat'*(deltaV - gammaV + u3 - u2) - (tauV + u4));
            H_g=gpuArray(H);
            h_g=gpuArray(h);
            w_hat = gather(- H_g\h_g);
%             w_hat = - H\h;
        end
        
        model.iter_w(:,it) = w_hat(1:end-1);
       
        model.wtau(:, it) = w_hat(1:end-1) - tauV(1:end-1);
        
        
        iter_obj(it) = 0.5*norm(w_hat(1:end)) + C*em'*max(betaV,0) + Cu*emU'*max(gammaV,0) + Cu*emU'*max(deltaV,0) + lamda*nnz(tauV(1:end-1));
        
        wxb = ValX*w_hat(1:end-1) + w_hat(end); 
        model.iter_PredictY(:,it) = sign( wxb );
        
       %% Step 3：update u and compute primal residual
       
        % Calculating r_norm
        r = [betaV - em + Y*X_hat*w_hat;...
             gammaV + epsilon*emU - Xu_hat*w_hat;...
             deltaV + epsilon*emU + Xu_hat*w_hat;...
             tauV - w_hat];

        s = rho*(w_hat-w_hat0);
        
        iter_r(:,it) = r;     iter_s(:,it) = s;
        
        iter_r_norm(it) = norm(r);
        iter_s_norm(it) = norm(s);
        
        % u
        if Para.L0USVM.UpdateU == "ON"
            u = [u1; u2; u3; u4] +  eta *  (1./it) * r ;
        else
            u = [u1; u2; u3; u4] + r ;
        end
        u1 = u(1:m);
        u2 = u(m+1:m+mU);
        u3 = u(m+mU+1:m+2*mU);
        u4 = u(m+2*mU+1:end);
        
        model.iter_u1(:,it) = u1;       model.iter_u2(:,it) = u2;   
        model.iter_u3(:,it) = u3;       model.iter_u4(:,it) = u4;   
        
        % -------- stopping criterion ------
        if norm(r)<=eps_pri && norm(s)<=eps_dual
           break;
        elseif it > itmax
           break;
        end
        
    end
    
    %% --------------------- 3.Out of model --------------------------
     tr_time = toc(tt); 
     model.it = it;
     
     model.tr_time = tr_time;
     model.w = w_hat(1:end-1);
     model.b = w_hat(end);
     model.tau = tauV(1:end-1);
     
     wxb = ValX*model.w + model.b; 
     PredictY = sign( wxb );
     
     model.w_ind = ~tauV(1:end-1);     % (w=0 corresponds to useless feature)
     model.spsN = nnz(~tauV(1:end-1)); % SParSe Number, # useless fea 
     model.nFea = n; 
     model.spsR = model.spsN / n *100; % SParSe Ratio, % useless fea 
     model.n_SV = nnz(model.w);
     model.n_wks = -1;
     
     % iter
     model.iter_obj = iter_obj;
     model.n_iter = itmax;
     model.iter_r_norm = iter_r_norm;
     model.iter_s_norm = iter_s_norm;
     
     % model.iter_PredictY = iter_PredictY;
     model.iter_r = iter_r;
     model.iter_s = iter_s;
     model.iter_rho_1 = iter_rho_1;
     model.iter_rho_2 = iter_rho_2;
     model.iter_rho_3 = iter_rho_3;
     model.iter_rho_4 = iter_rho_4;
     
     model.iter_beta = iter_betaV;
     model.tauV = tauV;
     model.iter_tauV = iter_tauV;
     
end