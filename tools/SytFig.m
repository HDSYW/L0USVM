clc;clear
% 数据准备
true_features = [2, 2, 2, 2, 2];
% noise_features = [8, 8, 5, 8, 0];

noise_features = [1998, 1684, 45, 1998, 35];
% 横坐标标签
methods = ["SVM", "$\ell_2$-$\ell_1$-USVM", "$\ell_1$-USVM", "USVM", "$\ell_0$-USVM"];

% 绘图
figure;
% yyaxis left
h = bar([true_features; noise_features]', 'stacked');
set(h, 'BarWidth', 0.5);  % 默认是 0.8，0.6 会增加间隔

% 设置颜色
h(1).FaceColor = [0 0.4470 0.7410];     % 蓝色（Selected true features）
h(2).FaceColor = [0.6 0.6 0.6];         % 灰色（Selected noise features）

% 添加数值标签
for i = 1:length(true_features)
    if true_features(i) > 0
        text(i, true_features(i)/2, num2str(true_features(i)), 'Color', 'w', ...
            'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    if noise_features(i) > 0
        text(i, true_features(i) + noise_features(i)/2, num2str(noise_features(i)), ...
            'Color', 'w', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
end

% 设置横坐标
set(gca, 'xticklabel', methods); % 设置横坐标位置
set(gca, 'TicklabelInterpreter', 'latex'); % 设置横坐标位置
% xticklabels(methods,'interpreter','latex');  % 手动设置标签
ylabel('Feature number', 'FontWeight', 'bold');

% 添加红色虚线（参考线）
hold on;
yline(2, 'r--', 'LineWidth', 1);  % True features数量线
% yline(10, 'r--', 'LineWidth', 1); % 总特征数量线
yline(2000, 'r--', 'LineWidth', 1); % 总特征数量线
set(gca, 'YScale', 'log')
% 添加图例
legend('Selected true features', 'Selected noise features', ...
      'Orientation', 'horizontal','Location','north');
set(legend,'box','off')
% 美化
% ylim([0 11.5]);
% ylim([0 2020]);
box off;
set(gca, 'LooseInset', [0, 0, 0, 0]);

% yyaxis right
% plot(1:5,[100,100,100,100,100],Color=[230/255,138/255,46/255],Marker="pentagram",MarkerSize=14,MarkerFaceColor=[255/255,215/255,0/255],LineWidth=1.5)