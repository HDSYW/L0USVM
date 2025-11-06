function [ Perfm, Para, ModT ] = SearchOptParas( Data, ModelNameFun, Para, fid)
    % CopyRigth: Junshan Yin; LastUpdate: 2023-8-31

    [~, n] = size(Data.X);
    
    %% Step1：Search Para
    indctmjr = Para.indctmjr;       CVM = Para.CVM;
    Grid_M1 = Para.M1;              Grid_M2 = Para.M2;
    Grid_M3 = Para.M3;              Grid_M4 = Para.M4;
    Grid_K1 = Para.kp1;             Grid_K2 = Para.kp2;
    Bst_indct = -1;                 Bst_indct2 = 0;         %% 1.AC ; 2.spsR ;
    [Opt.p1,Opt.p2,Opt.p3,Opt.p4,Opt.kp1,Opt.kp2] = deal(0);          Prcs = 0;
    
    if Para.GroupsNumber == 1
        Opt.p1 = Grid_M1;    Opt.p2 = Grid_M2;
        Opt.p3 = Grid_M3;    Opt.p4 = Grid_M4;
        Opt.kp1= Grid_K1;    Opt.kp2= Grid_K2;
        fprintf('Groups Number = 1, so it is opt Para\n')
    else
        for i1 = Grid_M1
            for i2 = Grid_M2
                for i3 = Grid_M3
                    for i4 = Grid_M4
                        for i5 = Grid_K1
                            for i6 = Grid_K2
                                Para.p1 = i1;           Para.p2 = i2;
                                Para.p3 = i3;           Para.p4 = i4;
                                Para.kpar.kp1 = i5;     Para.kpar.kp2 = i6;
                                %----------------------------------------
                                [Perfm, model] = CV_Method( Data, ModelNameFun, Para);
                                [Bst_indct, Bst_indct2, Opt] = OptParaMethod(Perfm, model, Para, Bst_indct, Bst_indct2, Opt);
                            end % K2
                        end % K1
                    end % M4
                end % M3
            end % M2
            Prcs = Prcs + 1/length(Grid_M1);
            fprintf('Prcs %.2f, %s:%.4f, p1:%.8f, p2:%.8f, p3:%.8f, p4:%.8f, kp1:%.8f, kp2:%.8f\n',...
                Prcs, indctmjr, Bst_indct, Opt.p1, Opt.p2, Opt.p3, Opt.p4, Opt.kp1, Opt.kp2); % Process Report
        end % M1
    end
    %% Step 2：Optimal Parameters Collection 
    for i = "Para Collection"
        fprintf('Grid Parameter Seaching is over: \n');
        Para.p1 = Opt.p1;      Para.p2 = Opt.p2;      Para.p3 = Opt.p3;      Para.p4 = Opt.p4;
        Para.kpar.kp1 = Opt.kp1;               Para.kpar.kp2 = Opt.kp2;
        
        fprintf('───────────── Optimal Parameters ─────────────\n');
        fprintf('p1:%.4f    p2:%.4f    p3:%.4f    p4:%.4f    kp1:%.4f    kp2:%.2f',Opt.p1,Opt.p2,Opt.p3,Opt.p4,Opt.kp1,Opt.kp2);
        fprintf('\n──────────────────────────────\n');
    end
    
    %% Step 3 : C-Times CrossValidation Performance 
    if Para.RepeatOptPara == "ON"
        rpt = Para.indctRpt; % [repeat]-times CV, takes the mean
        fprintf('%d Times CrossValidation Experments with Opt-Paras are Starting... \n', rpt);
        fprintf('──────────── %d×%s Performance ─────────────\n', rpt, CVM);
        [Acs,GMs,Sens,Spes,Times,N_SVs,spsNs,spsRs,Niters,Nwkss] = deal(zeros(rpt,1));
        wids = zeros(n,1);
        
        for ir = 1 : rpt
            [Perfm , ~] = CV_Method( Data, ModelNameFun, Para);
            Acs(ir) = Perfm.Ac;                GMs(ir) = Perfm.GM;
            Sens(ir) = Perfm.Sen;            Spes(ir) = Perfm.Spe;
            Times(ir) = Perfm.tr_time;    N_SVs(ir) = Perfm.n_SV;
            if Para.FS==1
                spsNs(ir) = Perfm.spsN;      spsRs(ir) = Perfm.spsR;
                wids = wids + Perfm.wids;
            end
            if Para.ITER == 1
                Niters(ir) = Perfm.Niters;
                Nwkss(ir) = Perfm.Nwkss;
            end
        end
        if indctmjr=="AC",tmp=Acs; elseif indctmjr=="GM",tmp=GMs; end
        index_all = [Acs,GMs,Sens,Spes,Times,N_SVs];
        m_all = num2cell(mean(index_all));
        s_all = num2cell(std(index_all));
        [mAc,mGM,mSen,mSpe,mTime,mN_SV] = m_all{:};
        [sAc,sGM,sSen,sSpe,sTime,sN_SV] = s_all{:};
        
        fprintf('%d×%s: [', rpt, indctmjr);        fprintf('%.4f ',tmp);       fprintf(']');
        fprintf('\nmAcc:%.4f | sAcc:%.4f     mGM: %.4f | sGM:%.4f\n', mAc, sAc, mGM, sGM );
        fprintf('mSen:%.4f | sSen:%.4f     mSpe:%.4f | sSep:%.4f\n', mSen, sSen, mSpe, sSpe );
        fprintf('mTime:%.6f(%.6f)\tmN_SV:%.2f(%.2f)', mTime, sTime, mN_SV, sN_SV );
        if Para.FS==1
            mspsN=mean(spsNs); sspsN=std(spsNs);
            mspsR=mean(spsRs); sspsR=std(spsRs);
            fprintf('\nmspsN:%.1f(in%d) | sspsN:%.2f\tmspsR:%.3f | sspsR:%.2f', ...
                mspsN, n, sspsN, mspsR, sspsR );
        end
        if Para.ITER==1
            mNiter=mean(Niters); sNiter=std(Niters);
            mNwks=mean(Nwkss); sNwks=std(Nwkss);
            fprintf('\nmNiter:%.2f | sNiter:%.2f\tmNwks:%.3f | sNwks:%.2f', ...
                mNiter, sNiter, mNwks, sNwks );
        end
        fprintf('\n──────────────────────────────\n');
    else
        Perfm = -1;
    end
    %% Step 4 : Total/Test Performance  
    
    
    if Para.DS=="Training+Validation"   % ___ Total Performance 
        [PredY, ModT] = ModelNameFun( Data.X , Data , Para ); 
        CM = ConfusionMatrix(PredY,Data.Y);    tt = 'Total(×)'; 
        Para.data_TstY = Data.Y;
        
    elseif Para.DS=="Training+Validation+Testing"  % ___ Test Performance 
        [PredY, ModT] = ModelNameFun( Data.TstX , Data , Para ); 
        CM = ConfusionMatrix(PredY,Data.TstY);    tt = 'Test';
        Para.data_TstY = Data.TstY;
    end
    
    [tAc, tGM, tSen, tSpe] = deal(CM.Ac, CM.GM, CM.Sen, CM.Spe);
    tTime = ModT.tr_time;    tN_SV = ModT.n_SV;
    fprintf('%s Data Experment with Opt-Paras is Starting... \n', tt);
    fprintf('───────────── %s Performance ─────────────\n', tt);
    fprintf('tAcc:%.4f  |  tGM:%.4f  |  tSen:%.4f  |  tSpe:%.4f\n', tAc, tGM, tSen, tSpe);
    fprintf('tTime:%.6f  |  tN_SV:%d', tTime, tN_SV);
    Para.tAc = tAc;
    if Para.ITER==1 
        fprintf('  |  tNiter:%.2f', ModT.n_iter);
    end
    if Para.FS==1,fprintf('  |  tspsN:%d(in%d)  |  tspsR:%.2f', ModT.spsN, n, ModT.spsR);end
    fprintf('\n───────────────────────────────────\n');
   
    %% Step 5 : Auto Write In 

    if fid ~= -10 
        %  Optimal Parameters
        fprintf(fid,'───────────── Optimal Parameters ─────────────\n');
        fprintf(fid,'p1:%.4f    p2:%.4f    p3:%.4f    p4:%.4f    kp1:%.4f    kp2:%.2f',...
                Opt.p1, Opt.p2, Opt.p3, Opt.p4, Opt.kp1, Opt.kp2 );  
        
        % C-Times CrossValidation Performance
        if Para.RepeatOptPara == "ON"
            fprintf(fid,'\n───────────── %d×%s Performance ─────────────\n', rpt, CVM);
            fprintf(fid,'\n%d×%s: [', rpt, indctmjr);        fprintf(fid,'%.4f ',tmp);       fprintf(fid,']');
            fprintf(fid,'\nmAcc:%.4f | sAcc:%.4f      mGM:%.4f | sGM:%.4f\n', mAc, sAc, mGM, sGM );
            fprintf(fid,'mSen:%.4f | sSen:%.4f      mSpe:%.4f | sSep:%.4f\n', mSen, sSen, mSpe, sSpe );
            fprintf(fid,'mTime:%.6f(%.6f)\tmN_SV:%.2f(%.2f)', mTime, sTime, mN_SV, sN_SV );
            if Para.FS==1
                fprintf(fid,'\nmspsN:%.1f(in%d) | sspsN:%.2f\tmspsR:%.3f | sspsR:%.2f',mspsN,n,sspsN,mspsR,sspsR);
            end
            if Para.ITER==1
                fprintf(fid,'\nmNiter:%.2f | sNiter:%.2f\tmNwks:%.3f | sNwks:%.2f',mNiter, sNiter, mNwks, sNwks );
            end
            fprintf(fid,'\n───────────────────────────────────\n');
        end
        
        % Test / Total Performance 
        fprintf(fid,'\n───────── %s Performance ─────────\n', tt);
        fprintf(fid,'tAcc:%.4f  |  tGM:%.4f  |  tSen:%.4f  |  tSpe:%.4f\n', tAc, tGM, tSen, tSpe);
        fprintf(fid,'tTime:%.6f  |  tN_SV:%d', tTime, tN_SV);
        if Para.FS==1,fprintf(fid,'  |  tspsN:%d(in%d)  |  tspsR:%.2f', ModT.spsN, n, ModT.spsR);end
        if Para.ITER==1,fprintf(fid,'  |  tNiter:%.2f  |  tNwks:%.2f', ModT.n_iter, ModT.n_wks);end
        fprintf(fid,'\n───────────────────────────────────\n');
        
    end % end fid
    
end