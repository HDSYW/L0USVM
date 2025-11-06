% Copyright：Junshan Yin
% Last updated: 2024-5-14
rng(942)

clc;clear
%% Import Data
Para.datName = 'HQC_130377x655';
mat_path = strcat('./00-DemoData/',Para.datName,'.mat');
Data = load(mat_path); [~,n] = size(Data.X); Para.n = n;
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
        M1 = 2.^[-2];  
        M2 = 2.^[-8];  
        M3 = 2.^[-8]; 
        M4 = 10.^[-3]; 
        
        Para.rho = 0.0001; %0.0001                      Para.Update_rho = "OFF";
        Para.utype = 'MidPoint';         Para.inti_w = "OFF";
        Para.eta = 8;                    Para.L0USVM.UpdateRho = "OF";
        Para.itmax = 100;                Para.L0USVM.UpdateU = "ON";
        Para.WrokSet = "ON";             Para.L0USVM.WorkSetRatio = 0.96;
        Para.ITER = 1;
        
     elseif sum(ModelName=="L1n_L1SVC")
        M1 = 32;      %C
        
    elseif sum(ModelName == "LIB_L1SVC")
        M1 = 256;
        
    elseif sum(ModelName == "L2L1n_L1SVC")
        M1 = 256;
        M2 = 64;
        
    elseif sum(ModelName == "USVM")
        M1 = 0.0313;  %C
        M2 = 256;     %Cu
        M3 = 1;       %epsilon
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
    
    %% Draw the iteration diagram of L0USVM and save var
    if ModelName == "L0USVM"
       % Draw
       Time = datestr(now,'yyyy-mm-dd_HH-MM-SS');    Para.Time = Time;
       Para.FolderPath = '03-LastRunFig';
%        L0_USVM_IterFig(Para,ModT)
       F(Para,ModT)
       %
       mat_path = './05-IterInfo/';
       if exist(mat_path,'dir') == 0
           mkdir(mat_path)
       end
       
       save(strcat(mat_path,Para.run_name,'.mat'),'ModT')
    end

    ArticleTableResults(ModelName,Para,ModT)
end
