function omega = kernelfun(Xtrain,kerfPara,Xt)
% Construct the positive (semi-) definite and symmetric kernel matrix
%
% >> Omega = kernelfun(X, kernel_fct, sig2)
%
% This matrix should be positive definite if the kernel function
% satisfies the Mercer condition. Construct the kernel values for
% all test data points in the rows of Xt, relative to the points of X.
%
% >> Omega_Xt = kernelfun(X, kernel_fct, sig2, Xt)
%
%
% Full syntax
%
% >> Omega = kernelfun(X, kernel_fct, sig2)
% >> Omega = kernelfun(X, kernel_fct, sig2, Xt)
%
% Outputs
%   Omega  : N x N (N x Nt) kernel matrix
% Inputs
%   X      : N x d matrix with the inputs of the training data
%   kernel : Kernel type (by default 'RBF_kernel')
%   sig2   : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%   Xt(*)  : Nt x d matrix with the inputs of the test data
kernel_type = kerfPara.type;
kernel_pars = kerfPara.pars1;

nb_data = size(Xtrain,1);

if strcmp(kernel_type,'rbf'),
    if nargin<3,
        XXh = sum(Xtrain.^2,2)*ones(1,nb_data);
        omega = XXh+XXh'-2*(Xtrain*Xtrain');
        omega = exp(-omega./(2*kernel_pars(1)^2));
    else
        omega = - 2*Xtrain*Xt';
        Xtrain = sum(Xtrain.^2,2)*ones(1,size(Xt,1));
        Xt = sum(Xt.^2,2)*ones(1,nb_data);
        omega = omega + Xtrain+Xt';
        omega = exp(-omega./(2*kernel_pars(1)^2));
    end
    
elseif strcmp(kernel_type,'rbf4'),
    if nargin<3,
        XXh = sum(Xtrain.^2,2)*ones(1,nb_data);
        omega = XXh+XXh'-2*(Xtrain*Xtrain');
        omega = 0.5*(3-omega./kernel_pars).*exp(-omega./(2*kernel_pars(1)));
    else
        Xtrain = sum(Xtrain.^2,2)*ones(1,size(Xt,1));
        Xt = sum(Xt.^2,2)*ones(1,nb_data);
        omega = Xtrain+Xt' - 2*Xtrain*Xt';
        omega = 0.5*(3-omega./kernel_pars).*exp(-omega./(2*kernel_pars(1)));
    end
    
% elseif strcmp(kernel_type,'sinc'),
%     if nargin<3,
%         omega = sum(Xtrain,2)*ones(1,size(Xtrain,1));
%         omega = omega - omega';
%         omega = sinc(omega./kernel_pars(1));
%     else
%         XXh1 = sum(Xtrain,2)*ones(1,size(Xt,1));
%         XXh2 = sum(Xt,2)*ones(1,nb_data);
%         omega = XXh1-XXh2';
%         omega = sinc(omega./kernel_pars(1));
%     end
    
elseif strcmp(kernel_type,'lin')
    if nargin<3,
        omega = Xtrain*Xtrain';
    else
        omega = Xtrain*Xt';
    end
    
elseif strcmp(kernel_type,'poly')
    if nargin<3,
        omega = (Xtrain*Xtrain'+kernel_pars(1)).^kernel_pars(2);
    else
        omega = (Xtrain*Xt'+kernel_pars(1)).^kernel_pars(2);
    end
    
% elseif strcmp(kernel_type,'wav_kernel')
%     if nargin<3,
%         XXh = sum(Xtrain.^2,2)*ones(1,nb_data);
%         omega = XXh+XXh'-2*(Xtrain*Xtrain');
%         
%         XXh1 = sum(Xtrain,2)*ones(1,nb_data);
%         omega1 = XXh1-XXh1';
%         omega = cos(kernel_pars(3)*omega1./kernel_pars(2)).*exp(-omega./kernel_pars(1));
%         
%     else
%         XXh1 = sum(Xtrain.^2,2)*ones(1,size(Xt,1));
%         XXh2 = sum(Xt.^2,2)*ones(1,nb_data);
%         omega = XXh1+XXh2' - 2*(Xtrain*Xt');
%         
%         XXh11 = sum(Xtrain,2)*ones(1,size(Xt,1));
%         XXh22 = sum(Xt,2)*ones(1,nb_data);
%         omega1 = XXh11-XXh22';
%         
%         omega = cos(kernel_pars(3)*omega1./kernel_pars(2)).*exp(-omega./kernel_pars(1));
%     end
end