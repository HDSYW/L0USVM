function F(Para,ModT)

FolderPath = strcat(Para.FolderPath,'/IterInfo_',Para.ModelName);
if exist(FolderPath, 'dir') == 0
    mkdir(FolderPath)
end

close all;
%% figgure 1
figure(1);
name{1}='Obj';
%---------------------------
% subplot(3, 3, 1);
iter_obj = ModT.iter_obj;
X = 1:length(iter_obj);
plot(X,iter_obj, 'k', 'LineWidth', 1.2,MarkerSize=12,Marker='.')
xlabel('Iteration Number',FontName='Times New Roman',FontWeight='bold')
ylabel('The objective value',FontName='Times New Roman',FontWeight='bold')
grid on
figurePosition = [100, 100, 500, 400];
set(gcf, 'Position', figurePosition);
set(gca, 'GridLineStyle', '--');
set(gca, 'LooseInset', [0, 0, 0, 0]);
% set(gca, 'Fontsize', 10);
% title(strcat('iter\_obj','(',num2str(length(iter_obj)),'/',num2str(ModT.n_iter),')')) %,'Interpreter', 'latex'

%---------------------------
% subplot(3, 3, 2);
figure(2);
name{2}='O_norm';
iter_r_norm = ModT.iter_r_norm;
X = 1:length(iter_r_norm);
plot(X,iter_r_norm, 'k', 'LineWidth', 1.2,Color=[21/255,151/255,165/255],MarkerSize=12,Marker='.')
xlabel('Iteration Number',FontName='Times New Roman',FontWeight='bold')
ylabel('The primal residual',FontName='Times New Roman',FontWeight='bold')

figurePosition = [100, 100, 500, 400];
set(gcf, 'Position', figurePosition);
grid on
set(gca, 'GridLineStyle', '--');
set(gca, 'LooseInset', [0, 0, 0, 0]);
% title(strcat('iter\_r\_norm','(',num2str(length(iter_r_norm)),'/',num2str(ModT.n_iter),')'))


%---------------------------
% subplot(3, 3, 3);
figure(3);
name{3}='R_norm';
iter_s_norm = ModT.iter_s_norm;
X = 1:length(iter_s_norm);
plot(X, iter_s_norm, 'k', 'LineWidth', 1.2,Color=[3/255,50/255,80/255],MarkerSize=12,Marker='.')
xlabel('Iteration Number',FontName='Times New Roman',FontWeight='bold')
ylabel('The dual residual',FontName='Times New Roman',FontWeight='bold')

figurePosition = [100, 100, 500, 400];
set(gcf, 'Position', figurePosition);
grid on
set(gca, 'GridLineStyle', '--');
set(gca, 'LooseInset', [0, 0, 0, 0]);
% title(strcat('iter\_s\_norm','(',num2str(length(iter_s_norm)),'/',num2str(ModT.n_iter),')'))



%---------------------------
% subplot(3, 3, 4);
figure(4);
name{4}='Fea';
nnz_tau = ModT.iter_nnz_tau;
X = 1:length(nnz_tau);
plot(X,nnz_tau, 'k', 'LineWidth', 1.2,Color=[191/255,030/255,046/255],MarkerSize=12,Marker='.')
xlabel('Iteration Number',FontName='Times New Roman',FontWeight='bold')
ylabel('Number of selected features',FontName='Times New Roman',FontWeight='bold')

figurePosition = [100, 100, 500, 400];
set(gcf, 'Position', figurePosition);
grid on
set(gca, 'GridLineStyle', '--');
set(gca, 'LooseInset', [0, 0, 0, 0]);
% title(strcat('iter\_nnz\_tau','(',num2str(length(iter_s_norm)),'/',num2str(ModT.n_iter),')'))

for i=1:4
    figs_path = strcat('./',name{i});
    save_fig_path = strcat(figs_path,'_',Para.datName);
    save_fig_path_fig = strcat(save_fig_path,'.fig');
%     save_fig_path_fig1 = strcat(save_fig_path,'.eps');
    saveas(figure(i), save_fig_path_fig);
%     saveas(figure(i), save_fig_path_fig1,'psc');
end

end