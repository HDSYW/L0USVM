function Data = AddUniversunData( Data , Para)
%% ————————————————————————————————————————————————————————
% A functiuon about Add Universum data .

%--------- inptu info --------------------------
%    Data.X ------- ori data
%    Data.Y ------- label of ori data
%    Data.X_zeros ------ the label equ 0 of ori data
%    Para.Uni_type -------- a way of create Universum

%--------- ouput info --------------------------
%    Data.Ux is Universum data
%    Data.Uy is lable if of Universum

% _________________________________________________________

% Written by Junshan Yin, lateset update: 2023.9.12.
    X = Data.X;     Y = Data.Y;
    ModelName = Para.ModelName;
    
    [m, n] = size(X);
    if nnz(ModelName == [Para.ModL0USVM;"L0_USVM";"L0_USVM_2"; "L0_USVM_3";"USVM";"USVM_1"])
        if Para.utype == "MidPoint"
            idx_pos = find(Data.Y == 1); idx_neg = find(Data.Y == -1);
            idx_length = min(length(idx_neg),length(idx_pos));
            % 正类点
            index_p1 = randperm(idx_length)';
            index_p2 = randperm(idx_length)';
            index_p = [index_p1;index_p2];
            data_p = Data.X(Data.Y == 1,:);
            point_p = data_p(index_p,:);
            
            % 负类点
            
            index_n1 = randperm(idx_length)';
            index_n2 = randperm(idx_length)';
            index_n = [index_n1;index_n2];
            data_n = Data.X(Data.Y == -1,:);
            point_n = data_n(index_n,:);
            
            % 计算正类点和负类点的中点
            Data.Ux = (point_p + point_n) / 2;
            Data.Uy = [ones(idx_length,1);-ones(idx_length,1)] ;
            
        elseif Para.utype == "OtherClass"
            [Ux_num,~] = size(Data.X_zeros);
            Data.Ux = Data.X_zeros ;
            p = round(Ux_num/2);
            Data.Uy = [ones(p,1); -ones(Ux_num-p,1)];
        end
    end
    %%
    if nnz(ModelName == ["VV_USVC";"VV_UL1SVC"])
        [~, n] = size(Data.X); en = ones(n,1);
        uni = eye(n);
        Data.Ux = sparse([uni;uni]);
        Data.Uy = [ en ; -en ];
    end
    
    %%
    if nnz(ModelName == ["FSSVC_ADMM_allUni_Y1"])
        [m,n] = size(Data.X);
        mU = m*n;
        Ux = zeros(mU,n);
        
        for j = 1:n
            Ux(m*(j-1)+1:m*j, j)  = Data.X(:, j);
            Uy(m*(j-1)+1:m*j, :)  = Data.Y;
        end
        
        Data.Ux = Ux;       Data.Uy = Uy;
    end
    
    %%
    if nnz(ModelName == ["FSSVC_ADMM_allUni_Y1";"FSSVC_ADMM_allUni_Version2"])
        [~,n] = size(Data.X);
        Ux = zeros(n,n);
        
        for ii = 1:n
            Ux(ii,ii) = 1;
            Uy = Data.Y;
            
        end
        Data.Ux = Ux;       Data.Uy = Uy;
        %          Data.Ux = [Ux;-Ux];       Data.Uy = [Uy;Uy];
    end
    

end