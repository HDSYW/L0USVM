function [Perfm, model] = CV_Method( Data, ModelNameFun, Para)
    % CopyRigth: Junshan Yin ；LastUpdate : 2023-8-31
    
    %% 1.Input data
    X = Data.X;     Y = Data.Y;     [~, n] = size(X);
    
    %% 2.Cross-Validation-Index Division
    CVM = Para.CVM;    BOC = Para.BOC;    MEN = Para.MEN;
    if CVM=="Kfold" 
        K = Para.cvp1; % # of disjoint subsets, [5] default 
        if BOC=="ON"
                if MEN=="ON"
                    men_p = floor(sum(Y==1)/K); 
                    men_n = floor(sum(Y==-1)/K); 
                    ind_p = crossvalind('Kfold',Y,K,'CLASSES',1,'MIN', men_p); 
                    ind_n = crossvalind('Kfold',Y,K,'CLASSES',-1,'MIN', men_n); 
                elseif MEN=="OFF"
                    ind_p = crossvalind('Kfold',Y,K,'CLASSES',1); 
                    ind_n = crossvalind('Kfold',Y,K,'CLASSES',-1); 
                end
                ind = ind_p + ind_n ;
            elseif BOC=="OFF"
                if MEN=="ON"
                    men = floor(length(Y)/K); 
                    ind = crossvalind('Kfold',Y,K,'MIN',men); 
                elseif MEN=="OFF"
                    ind = crossvalind( 'Kfold' , Y , K ); % default 
                end
        end 
    end % end Kfold
    
    %% 3.Cross-Validation Main Process
    if CVM=="Kfold" 
        Perfm.n_SV = 0;    Perfm.tr_time = 0; 
        PredYs = [];    ValYs = []; 
        if Para.FS==1, wids=zeros(n,1); spsNs = 0; spsRs = 0; end
        if Para.ITER==1, Niters = 0; Nwkss = 0; end
        for ik = 1 : K
            ind_val = (ind == ik);         ind_trn = ~ind_val; 
            Trn.X = X(ind_trn,:);          Trn.Y = Y(ind_trn,:); 
            Val.X = X(ind_val,:);          Val.Y = Y(ind_val,:); 
            Trn.X = full(Trn.X);           Val.X = full(Val.X);
            if Para.UNI == 1
                Trn.Ux = Data.Ux;       Trn.Uy = Data.Uy;
            end
            
            "_____>>>>>> Modeling and Prediction <<<<<<<<<_____";
            [PredY, model] = ModelNameFun( Val.X , Trn , Para );
            
            if contains(func2str(ModelNameFun),'L0_USVM') && Para.Update_rho == "ON"
                Para.Stop = 0;
                while 1
                    [PredY, model] = ModelNameFun( Val.X , Trn , Para );
                    
                    if Para.Stop == 0
                        break;
                    end
                end
            end
            "-------------------------------------------";
            Perfm.n_SV = Perfm.n_SV + model.n_SV;
            Perfm.tr_time = Perfm.tr_time + model.tr_time;
            PredYs = [PredYs;PredY];            ValYs = [ValYs;Val.Y];
            
            if Para.FS==1 
                wids = wids + model.w_ind; % useful ind of w in the loop
                spsNs = spsNs + model.spsN; spsRs = spsRs + model.spsR; 
            end
            if Para.ITER == 1 
                Niters = Niters + model.it; 
            end
        end 
    end
    
    %% 4.Valuation Indices Collection
    CM = ConfusionMatrix( PredYs, ValYs ); 
    Perfm.Ac = CM.Ac;   Perfm.Spe = CM.Spe;
    Perfm.Er = CM.Er;   Perfm.Sen = CM.Sen;
    Perfm.GM = CM.GM;
%     Perfm.BER = CM.BER;
%     Perfm.BAR = CM.BAR;
    if CVM=="Kfold" %|| CVM=="LeaveMOut"
        Perfm.n_SV = Perfm.n_SV / K;    Perfm.tr_time = Perfm.tr_time / K;
        
        if Para.FS==1 
            Perfm.wids = wids / K;
            Perfm.spsN = spsNs / K; 
            Perfm.spsR = spsRs / K;
        end
        
        if Para.ITER == 1
            Perfm.Niters = Niters / K; 
            Perfm.Nwkss = Nwkss / K;
        end
    else
        fprintf('CVM is error!!')
    end
end