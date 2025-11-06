function [dPth] = SettingData
    %-------------------------- 01-Artificial Data(2-Dim) -----------------
    dPth(1)= {'./02-Exp_Data/01-ArtificialData(2_Dim)/data_100x10.mat'};
    dPth(2)= {'./02-Exp_Data/01-ArtificialData(2_Dim)/data_100x150.mat'};
    dPth(3)= {'./02-Exp_Data/ExampleData/2_Dim/data_200x2.mat'};

    dPth(4)= {'./02-Exp_Data/5_Dim/data_200x100.mat'};
    dPth(5)= {'./02-Exp_Data/5_Dim/data_200x300.mat'};
    
    %----------------------------- 02-WeiBo ---------------------------
    dPth(200)= {'./02-Exp_Data/02-WeiBo/data_1200x1000.mat'};     % The number of U is 200
    dPth(201)= {'./02-Exp_Data/02-WeiBo/data_1200x2000.mat'};     % The number of U is 200
    dPth(202)= {'./02-Exp_Data/02-WeiBo/data_1000x1000U200.mat'}; % The number of U is 200
    dPth(203)= {'./02-Exp_Data/02-WeiBo/data_1000x2000U200.mat'}; % The number of U is 200
    dPth(204)= {'./02-Exp_Data/02-WeiBo/WeiBo_2000x1000_U200.mat'}; 
    dPth(205)= {'./02-Exp_Data/02-WeiBo/data_2000x2000_U200.mat'}; 
    
    
    
   
    %-------------------- 06-Internet_Movie_DataBase(IMDB) ----------------
    dPth(600)= {'./02-Exp_Data/02-IMBD/IMBD_data_Fea_10000.mat'};
    

    %-------------------- 07-LibSVM-News20(18846)) ------------------------
    dPth(200)= {'./02-Exp_Data/07-LibSVM-News20(18846)/NewsTestData.mat'};

    
    %-------------------- 12-rcv1.binary ----------------------------------
    dPth(1200)= {'./02-Exp_Data/12-rcv1.binary/rcv1_train.binary_20242x47236.mat'};
    dPth(1201)= {'./02-Exp_Data/12-rcv1.binary/rcv1_train.binary_2000x47236.mat'};
    dPth(1202)= {'./02-Exp_Data/12-rcv1.binary/rcv1_train.binary_4000x47236.mat'};
    
    
    %----------------------------- 14-GTSRB ---------------------------
    dPth(1400)= {'./02-Exp_Data/01-GTSRB/GTSRB_Fig5(200)_VS_Fig3(200)U_Fig2(50).mat'};
    dPth(1401)= {'./02-Exp_Data/01-GTSRB/GTSRB_Fig5(1000)_VS_Fig3(1000)U_Fig2(50).mat'};
    dPth(1402)= {'./02-Exp_Data/01-GTSRB/GTSRB_Fig5(200)_VS_Fig3(200)U_Fig2(200).mat'};
    dPth(1403)= {'./02-Exp_Data/01-GTSRB/GTSRB_Fig5(1000)_VS_Fig3(1000)U_Fig2(200).mat'};


    %----------------------------- 15-GHPDD ---------------------------
    dPth(1500)= {'./02-Exp_Data/15-GHPDD/global_house_processed.mat'};
    dPth(1501)= {'./02-Exp_Data/15-GHPDD/GHPDD_U.mat'};
    

    %----------------------------- 15-EVPD ---------------------------
    dPth(1502)= {'./02-Exp_Data/15-EVPD_U/EVPD_U.mat'};
    dPth(1503)= {'./02-Exp_Data/15-DHI/DHI.mat'};
    dPth(1504)= {'./02-Exp_Data/15-CCFD/CCFD.mat'};
    dPth(1505)= {'./02-Exp_Data/15-CIS/CIS_DF.mat'};
    dPth(1506)= {'./02-Exp_Data/hqc/HQC.mat'};
end



