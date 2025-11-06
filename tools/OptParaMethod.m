function [Bst_indct, Bst_indct2, Opt] = OptParaMethod(Perfm, model, Para, Bst_indct, Bst_indct2, Opt)
    % Input: 
    %     Perfm - Performance at Para, contains many indicators
    %     model - model at Para, contains many indicators
    %     Para - Current parameters
    %     Best_indct - Former best major indicator
    %     Best_indct2 - Former best minor indicator
    
    % Output:
    %     Best_indct - New best major indicator
    %     Best_indct2 - New best minor indicator
    %     Opt - New optimal parameters under certain conditions

    % Copyright: Junshan Yin Last Update：2023.8.31
    
    
    %% Step1：Major Indicator Declaration & Initialization
    if Para.indctmjr=="AC"
        Crt_indct = Perfm.Ac;
    elseif Para.indctmjr=="GM"
        Crt_indct = Perfm.GM;
    end % Current Indicator
    
    OPLg = str2func(Para.OPLogi); % Optimal Para Logical operation, [>=] or [>]
    
    %% Step 2.1 Standard Para Collection Module (Major Indicator only)
    if Para.UNI==1 && Para.FS==1 % FS%UNI, need Cu<Cr 
        if Crt_indct > Bst_indct 
            Bst_indct = Crt_indct;
            Opt.p1 = Para.p1;                   Opt.p2 = Para.p2;       
            Opt.p3 = Para.p3;                   Opt.p4 = Para.p4;
            Opt.kp1 = Para.kpar.kp1;            Opt.kp2 = Para.kpar.kp2;
        elseif Crt_indct == Bst_indct  &&  ... 
                Para.p1/Para.p2 <= Opt.p1/Opt.p2 % Cu/Cr later <= former
            Bst_indct = Crt_indct; 
            Opt.p1 = Para.p1;                   Opt.p2 = Para.p2;       
            Opt.p3 = Para.p3;                   Opt.p4 = Para.p4;
            Opt.kp1 = Para.kpar.kp1;            Opt.kp2 = Para.kpar.kp2;
        end
        
    elseif OPLg(Crt_indct , Bst_indct) % ___■ Classic Para Collection ■___
        Bst_indct = Crt_indct;
        Opt.p1 = Para.p1;                   Opt.p2 = Para.p2;       
        Opt.p3 = Para.p3;                   Opt.p4 = Para.p4;
        Opt.kp1 = Para.kpar.kp1;            Opt.kp2 = Para.kpar.kp2;
        
    end

end