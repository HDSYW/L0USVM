function [X_train, X_test, y_train, y_test, Ux, Uy] = generate_dataset(num_samples_per_class, num_true_features, num_noise_features, k1, k2, l1, l2)
    % 参数默认值设置
    if nargin < 1 || isempty(num_samples_per_class), num_samples_per_class = 100; end
    if nargin < 2 || isempty(num_true_features), num_true_features = 2; end
    if nargin < 3 || isempty(num_noise_features), error('必须指定噪声特征数量'); end
    if nargin < 4 || isempty(k1), k1 = 2; end
    if nargin < 5 || isempty(k2), k2 = 1; end
    if nargin < 6 || isempty(l1), l1 = 2; end
    if nargin < 7 || isempty(l2), l2 = 1; end
    
    % 生成原始数据
    mu_plus = [0.5*ones(1,num_true_features), zeros(1,num_noise_features)];
    sigma_plus = blkdiag(k1*eye(num_true_features), k2*eye(num_noise_features));
    X_plus = mvnrnd(mu_plus, sigma_plus, num_samples_per_class);
    
    mu_minus = [-0.5*ones(1,num_true_features), zeros(1,num_noise_features)];
    sigma_minus = blkdiag(l1*eye(num_true_features), l2*eye(num_noise_features));
    X_minus = mvnrnd(mu_minus, sigma_minus, num_samples_per_class);
    
    % 分层划分训练/测试集
    rng(42); % 固定随机种子
    [trainIdx_plus, testIdx_plus] = split_data(num_samples_per_class);
    [trainIdx_minus, testIdx_minus] = split_data(num_samples_per_class);
    
    % 构建数据集
    X_train = [X_plus(trainIdx_plus,:); X_minus(trainIdx_minus,:)];
    X_test = [X_plus(testIdx_plus,:); X_minus(testIdx_minus,:)];
    y_train = [ones(numel(trainIdx_plus),1); -ones(numel(trainIdx_minus),1)];
    y_test = [ones(numel(testIdx_plus),1); -ones(numel(testIdx_minus),1)];
    
%     % 数据混洗
%     shuffle_idx = @(x)randperm(size(x,1));
%     X_train = X_train(shuffle_idx(X_train),:);
%     y_train = y_train(shuffle_idx(y_train));
%     X_test = X_test(shuffle_idx(X_test),:);
%     y_test = y_test(shuffle_idx(y_test));

    % 生成Universum样本
    pos_samples = X_train(y_train == 1, :);  % 正类训练样本
    neg_samples = X_train(y_train == -1, :); % 负类训练样本
    num_pairs = min(size(pos_samples,1), size(neg_samples,1)); % 取较小类的数量
    
    % 随机配对正负样本
    rand_pos = randperm(size(pos_samples,1), num_pairs);
    rand_neg = randperm(size(neg_samples,1), num_pairs);
    
    % 计算特征平均值生成Universum
    Ux = (pos_samples(rand_pos,:) + neg_samples(rand_neg,:)) / 2;
    Uy = zeros(size(Ux,1),1); % Universum标签设为0
end

function [trainIdx, testIdx] = split_data(n)
    split = floor(0.7*n);
    idx = randperm(n);
    trainIdx = idx(1:split);
    testIdx = idx(split+1:end);
end

