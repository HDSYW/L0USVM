% 读取 PNG 图像
img = imread('L1n_L1SVC_2000.png');
[imgH, imgW, ~] = size(img);

% 创建 figure
figure;

% 创建一个主 axes 来显示图像
ax_img = axes('Position', [0.1, 0.1, 0.8, 0.8]); % 控制图片显示区域
imshow(img, 'Parent', ax_img);
axis(ax_img, 'image'); % 保持图像长宽比
axis(ax_img, 'off');   % 关闭坐标轴

% 保持图像为底层
uistack(ax_img, 'bottom');

% 创建一个覆盖在上面的透明 axes，用于绘图
ax_plot = axes('Position', ax_img.Position, 'Color', 'none');

% 生成示例数据
x = linspace(0, 10, 100);
AC = 50 + 50*sin(x);           % 范围 0-100
sparsity = 0.5 + 0.5*cos(x);   % 范围 0-1

% 左轴：AC
yyaxis(ax_plot, 'left');
ax = gca;          % 获取当前坐标轴句柄

% 设置左轴颜色（包括轴线、刻度、标签）
ax.YColor ='b'; % RGB 颜色，此处设为深绿色
% plot(x, AC, 'r-', 'LineWidth', 2);
ylabel('Accuracy (%)');
ylim([0 100]);

% 右轴：稀疏度
yyaxis(ax_plot, 'right');
% plot(x, sparsity, 'b--', 'LineWidth', 2);
ylabel('Sprasity (%)');
ylim([0 100]);
ax=gca;
set(ax.XLabel, 'Visible', 'off')

set(gca,'FontSize',12)
% 添加两个 annotation 箭头，位置为 [x_tail x_head], [y_tail y_head]
% 都是 normalized figure 坐标（0~1之间）

% 假设我们知道要指向的点大概在哪
% 左轴 AC = 75，大概在左中偏上位置
annotation('textarrow', ...
    [0.3 0.23], [0.6 0.6], ... % 横向箭头，指向左
    'String', '80.33%', ...
    'Color', 'b', ...
    'FontSize', 12);

% 右轴 稀疏度 = 0.8，大概在右上
annotation('textarrow', ...
    [0.7 0.77], [0.75 0.75], ... % 横向箭头，指向右
    'String', '99.35%', ...
    'Color', 'r', ...
    'FontSize', 12);


% 设置轴属性
% ax_plot.XColor = 'k';
% ax_plot.YColor = 'k';

% 如果不需要x轴，取消注释下面这一行
% ax_plot.XTick = [];

% 保存为 .fig
savefig('overlay_with_dual_axes.fig');
