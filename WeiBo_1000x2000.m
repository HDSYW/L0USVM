% Copyright：Junshan Yin
% Last updated: 2024-5-14

clc;clear
rng(1)

%% Import Data
Para.datName = 'WeiBo_1000x2000';
mat_path = strcat('./00-DemoData/',Para.datName,'.mat');
Data = load(mat_path); [~,n] = size(Data.X);Para.n = n;
Para.run_name = mfilename;
Para.plt = 0;

%% Paras
ModS = [];
% ModS = [ModS;"LIB_L1SVC"];
% ModS = [ModS;"L2L1n_L1SVC"];
% ModS = [ModS;"L1n_L1SVC"];
% ModS = [ModS;"USVM"];

ModS = [ModS,;"L0USVM"];

for mod = 1:length(ModS)
    ModelName = ModS(mod);  Para.ModelName = ModelName;
    fprintf('DataSet:%s, %s is training...\n',Para.datName,ModelName)
    fprintf('DemoCode :%s \n',Para.run_name)
    
    % Initialize model parameters
    [M1, M2, M3, M4] = deal(0);
    
    % Model parameter settings
    if sum(ModelName == "L0USVM")
        M1 = 2.^[8];
        M2 = 2.^[7];
        M3 = 2.^[-1];
        M4 = 10.^[-1];
        
        Para.rho = 1;                     Para.Update_rho = "OFF";    % rho = 0.9
        Para.eta = 0.009;                 Para.L0USVM.UpdateRho = "OF";
        Para.itmax = 100;                 Para.L0USVM.UpdateU = "ON";
        Para.WrokSet = "ON";              Para.L0USVM.WorkSetRatio = 0.99;
                                        
        
    elseif sum(ModelName=="L1n_L1SVC")
        M1 = 2.^[8];
        
    elseif sum(ModelName == "LIB_L1SVC")
        M1 = 2.^[8];
        Para.plt = 0;
        
    elseif sum(ModelName == "L2L1n_L1SVC")
        M1 = 2.^[8];
        M2 = 2.^[-1];
        
        
    elseif sum(ModelName == "USVM")
        M1 = 2.^[6];
        M2 = 2.^[6];
        M3 = 2.^[0];
    end
    
    Para.kpar.ktype = "lin";
    Para.kpar.kp1 = 0; Para.kpar.kp2 = 0;
    Para.p1 = M1;      Para.p2 = M2;      Para.p3 = M3;      Para.p4 = M4;
    ModelNameFun = str2func(ModelName);
    
    
    %% Output
    [PredY, ModT] = ModelNameFun( Data.TstX , Data , Para);
    Para.data_TstY = Data.TstY;
    CM = ConfusionMatrix(PredY, Data.TstY);    tt = 'Test';
    [tAc, tGM, tSen, tSpe] = deal(CM.Ac, CM.GM, CM.Sen, CM.Spe);
    tTime = ModT.tr_time;    tN_SV = ModT.n_SV;
    fprintf('%s Data Experment with Opt-Paras is Starting... \n', tt);
    fprintf('───────────── %s Performance ─────────────\n', tt);
    fprintf('tAcc:%.4f  |  tGM:%.4f  |  tSen:%.4f  |  tSpe:%.4f\n', tAc, tGM, tSen, tSpe);
    fprintf('tTime:%.6f  |  tN_SV:%d', tTime, tN_SV);
    Para.tAc = tAc;
    if ModelName == "L0USVM"
        fprintf('  |  tNiter:%.2f', ModT.n_iter);
    end
    fprintf('  |  tspsN:%d(in%d)  |  tspsR:%.2f', ModT.spsN, n, ModT.spsR);
    fprintf('\n───────────────────────────────────\n');
    
    %% Draw the iteration diagram of L0USVM
    if ModelName == "L0USVM"
       Time = datestr(now,'yyyy-mm-dd_HH-MM-SS');    Para.Time = Time;
       Para.FolderPath = '03-LastRunFig';
%        L0_USVM_IterFig(Para,ModT)
        F(Para,ModT)

    end
    %
       mat_path = './05-IterInfo/';
       if exist(mat_path,'dir') == 0
           mkdir(mat_path)
       end
       
       save(strcat(mat_path,Para.run_name,'.mat'),'ModT')
    
    
    ArticleTableResults(ModelName,Para,ModT)
    % save w
    mat_path = './06-WeiBo_w/Fea_2000/';
    if exist(mat_path,'dir') == 0
        mkdir(mat_path)
    end
    
    if ModelName == "L0USVM"
        w = ModT.tau;
    else
        w = ModT.w;
    end
    save(strcat(mat_path,ModelName,'.mat'),'w')
end