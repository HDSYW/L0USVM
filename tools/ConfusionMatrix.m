function CM = ConfusionMatrix( PredictY, TrueY )
% % Calculate the Confusion Matrix and 
% % other related evaluation indicators. 
% %     ┌───┬───────────┐
% %     │　 　 │    P R E D I C T     │
% %     ├───┼───┬───┬───┤
% %     │   T  │      │ ++   │  --  │
% %     │   R  ├───┼───┼───┤
% %     │   U  │ ++   │  TP  │ FN   │
% %     │   E   ├───┼───┼───┤
% %     │        │   --  │  FP  │  TN │
% %     └───┴───┴───┴───┘
% % Written by Lingwei Huang, lateset update: 2021.09.18. 
% Copyright 2021  Lingwei Huang. 

%% Intermediate Indicators  

    PY = PredictY;      TY = TrueY;   

    TP = nnz( PY(TY==1)==1 );     % # TURE Positive Prediction
    TN = nnz( PY(TY==-1)==-1 ); % # TURE Negative Prediction
    FP = nnz( PY(TY==-1)==1 );   % # FALSE Positive Prediction
    FN = nnz( PY(TY==1)==-1 );  % # FALSE Negative Prediction

    TPTN = TP + TN;  % # TURE Prediction
    FNFP = FN + FP;  % # FALSE Prediction
%     TPFP = TP + FP;   % # Positive Prediction
%     FNTN = FN + TN; % # Negative Prediction
%     TPFN = TP + FN;  % # Positive Label = mps
%     FPTN = FP + TN;  % # Negative Label = mng

    m = length(PY);       
    mps = TP + FN; % m_pos=nnz(PY==1)  
    mng = FP + TN; % m_neg=nnz(PY==-1)   
    [ CM.TP , CM.TN , CM.FP , CM.FN ] = deal( TP , TN , FP , FN );
    [ CM.TPTN , CM.FNFP ] = deal( TPTN , FNFP );     
    
%% Final Indicators

    Ac = TPTN / m * 100;
    Er = FNFP / m * 100;
    Sen = TP / mps * 100; 
    Spe = TN / mng * 100; 
    GM = sqrt( Sen * Spe ); 
%     BAR = 0.5 * (Sen+Spe); % Balacend Acc Rate = .5(Sen+Spe)
%     BER = 0.5 * (FN / mps + FP / mng) * 100; % Balacend Error Rate=1-BAR
    
    [ CM.Ac, CM.Er , CM.Sen , CM.Spe , CM.GM ] = ...
        deal( Ac , Er , Sen , Spe , GM );

end


