function L0_USVM_IterFig(Para,ModT)

    FolderPath = strcat(Para.FolderPath,'/IterInfo_',Para.ModelName);
    if exist(FolderPath, 'dir') == 0
        mkdir(FolderPath) 
    end
    
    close all;
    %% figgure 1
    figure(1);
    
    %---------------------------
    subplot(3, 3, 1);
    iter_obj = ModT.iter_obj;
    X = 1:length(iter_obj);
    plot(X,iter_obj, 'k', 'LineWidth', 1.2)
    title(strcat('iter\_obj','(',num2str(length(iter_obj)),'/',num2str(ModT.n_iter),')')) %,'Interpreter', 'latex'
    
    %---------------------------
    subplot(3, 3, 2);
    iter_r_norm = ModT.iter_r_norm;
    X = 1:length(iter_r_norm);
    plot(X,iter_r_norm, 'k', 'LineWidth', 1.2)
    title(strcat('iter\_r\_norm','(',num2str(length(iter_r_norm)),'/',num2str(ModT.n_iter),')'))
  
    
    %---------------------------
    subplot(3, 3, 3);
    iter_s_norm = ModT.iter_s_norm;
    X = 1:length(iter_s_norm);
    plot(X, iter_s_norm, 'k', 'LineWidth', 1.2) 
    title(strcat('iter\_s\_norm','(',num2str(length(iter_s_norm)),'/',num2str(ModT.n_iter),')'))
 
    
    
    %---------------------------
    subplot(3, 3, 4);
    nnz_tau = ModT.iter_nnz_tau;
    X = 1:length(nnz_tau);
    plot(X,nnz_tau, 'k', 'LineWidth', 1.2)
    
    title(strcat('iter\_nnz\_tau','(',num2str(length(iter_s_norm)),'/',num2str(ModT.n_iter),')'))
   

    %---------------------------
    subplot(3, 3, 5);
    
    p1_str = strcat('p1 = ',num2str(Para.p1)); p2_str = strcat('p2 = ',num2str(Para.p2));
    
    p3_str = strcat('p3 = ',num2str(Para.p3)); p4_str = strcat('p4 = ',num2str(Para.p4));
    L0_eta       = strcat('eta = ',num2str(Para.eta));
    
    L0_rho       = strcat('rho = ',num2str(Para.rho));
    L0_WrokSet   = strcat('WrokSet  = ',Para.WrokSet); 
    UpdateRho    = strcat('UpdateRho = ',Para.L0USVM.UpdateRho);
    UpdateU      = strcat('UpdateU  = ',Para.L0USVM.UpdateU);
    WorkSetRatio = strcat('WorkSetRatio = ',num2str(Para.L0USVM.WorkSetRatio));
    
   
    text(0.1, 0.6, {p1_str; p2_str; p3_str; p4_str; L0_eta}, 'FontSize', 10, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
    text(0.5, 0.6, {L0_rho; L0_WrokSet; UpdateRho; UpdateU; WorkSetRatio}, 'FontSize', 10, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')


    
    %% save file
    set(figure(1), 'WindowState', 'maximized');
    
    saveas(figure(1), strcat(FolderPath, '/','-',Para.datName,'_1','.png'));
    saveas(figure(1), strcat(FolderPath, '/','-',Para.datName,'_1','.fig'));
    
    
    figs_path = strcat('./02-OperationRecordFig/',Para.run_name);
    if exist(figs_path, 'dir') == 0
        mkdir(figs_path)
    end
    save_fig_path = strcat(figs_path,'/',Para.Time,'.png');
    save_fig_path_fig = strcat(figs_path,'/',Para.Time,'.fig');
    
    saveas(figure(1), save_fig_path);
    saveas(figure(1), save_fig_path_fig);
    
    % Obtain the width and height of the screen
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Define the position and size of the graphics window, for example, set it to half the screen width and height
    figurePosition = [screenWidth/4, screenHeight/4, screenWidth/2, screenHeight/2];

    % Set the position and size of the graphics window
    set(gcf, 'Position', figurePosition);
    
    





end