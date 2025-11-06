以下内容包含 2 个主要部分: 

    Ⅰ. LIBSVM修改: 命令窗口关闭输出; 

    Ⅱ. LIBSVM修改: 损失L2替换. 

■■■注意■■■: 警惕 [路径] 里的旧版文件顶替修改版文件被调用, 解决方式: 
    A. 检查当前运行的函数是否为需要的版本, 
         eg: 命令窗口[ which svmpredict ] 查看路径
    B. 尽量删除不需要的旧版工具包, 或函数重命名, 或在[设置路径]中将其移除; 
    C. 工具包主体libsvm-3.25可以不添加入 [路径] 中, 
        仅将几个主要函数复制到所需的 [路径] 下使用即可(读, 写, 训练, 预测)
        (libsvmread.mexw64, libsvmwrite.mexw64, svmtrain.mexw64, svmpredict.mexw64)



_______________________Ⅰ. LIBSVM 关闭输出修改_______________________
1. libsvm训练代码的参数设置部分，给字符串参数添加 '-q' 
eg: 
        lib_opt =  sprintf('-t 0 -c %f -q',c);
        model = svmtrain( Y , X , lib_opt );
        ......
---------------------------------------------------------
2. 修改文件 svmpredict.c  (.\libsvm-3.25\matlab\svmpredict.c)  
   (需.c编译器，如MinGW，把mingw.mlpkginstall拖进命令行窗口即可安装)
    A. 在 svmpredict.c 中搜索 [classification](or [regression]) 找到输出代码
    B. 注释前后几行(回归和分类输出)
eg: 
// 	if(svm_type==NU_SVR || svm_type==EPSILON_SVR)
// 	{
// 		info("Mean squared error = %g (regression)\n",error/total);
// 		info("Squared correlation coefficient = %g (regression)\n",
// 			((total*sumpt-sump*sumt)*(total*sumpt-sump*sumt))/
// 			((total*sumpp-sump*sump)*(total*sumtt-sumt*sumt))
// 			);
// 	}
// 	else
// 		info("Accuracy = %g%% (%d/%d) (classification)\n",
// 			(double)correct/total*100,correct,total);
        ......
---------------------------------------------------------
3. 重新编译
    A. 当前文件夹设为 .\libsvm-3.24\matlab 
    B. 运行函数 make
    C. 等待生成新的 .mexw64 文件
---------------------------------------------------------
4. 文件替换
    将文件 .\libsvm-3.24\matlab\svmpredict.mexw64 
    复制到 .\libsvm-3.24\windows\svmpredict.mexw64 
    替换原有文件
    或依据需要重命函数名，并覆盖其他旧版文件
---------------------------------------------------------
5. 禁止输出完成
官方说明: https://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f417
---------------------------------------------------------



______________________Ⅱ. LIBSVM 损失L2替换修改______________________
修改文件 svm.cpp  (.\libsvm-3.25\svm.cpp) : 
官方说明: https://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f422
步骤按代码前后出现顺序, 
将下列操作修改完后重新编译: 
    A. 当前文件夹设为 .\libsvm-3.24\matlab 
    B. 运行函数 make
    C. 等待生成新的 .mexw64 文件 (svmtrain.mexw64)

1.  关于 L2Loss-SVC 

A. 在 [class SVC_Q: public Kernel] 的 [public:] 的 [SVC_Q] 中, 在
        for(int i=0;i<prob.l;i++)
之前增加
        this->C = param.C;  // L2LOSS added 

B. 在 [class SVC_Q: public Kernel] 的 [public:] 的 [SVC_Q] 中, 在
        for(int i=0;i<prob.l;i++)
的内部将
            QD[i] = (Qfloat)(this->*kernel_function)(i,i); // L1LOSS
替换为
            QD[i] = (this->*kernel_function)(i,i)+0.5/C;  // L2LOSS replaced

C. 在 [class SVC_Q: public Kernel] 的 [public:] 的 [Qfloat *get_Q] 中, 将
            if(i >= start && i < len)   // L2LOSS added
            data[i] += 0.5/C;  // L2LOSS added
添加在
            for(j=start;j<len;j++)
                data[j] = (Qfloat)(y[i]*y[j]*(this->*kernel_function)(i,j));
之后(if的缩进和for相同)

D. 在 [class SVC_Q: public Kernel] 的 [private:] 中, 增加
    double C;  // L2LOSS added 

E. 在 [static void solve_c_svc] 的 [Solver s;] 中, 将
    s.Solve(l, SVC_Q(*prob,*param,y), minus_ones, y,
        alpha, Cp, Cn, param->eps, si, param->shrinking);  // L1LOSS
替换为
    s.Solve(l, SVC_Q(*prob,*param,y), minus_ones, y,
        alpha, INF, INF, param->eps, si, param->shrinking);  // L2LOSS replaced

---------------------------------------------------------

2.  关于 eps-L2Loss-SVR 

A. 在 [class SVR_Q: public Kernel] 的 [public:] 的 [SVR_Q] 中, 在
        for(int k=0;k<l;k++)
之前增加
        this->C = param.C;  // eL2LOSS added

B. 在 [class SVR_Q: public Kernel] 的 [public:] 的 [SVR_Q] 中, 在
        for(int k=0;k<l;k++)
的内部将
            QD[k] = (this->*kernel_function)(k,k); // eL1LOSS
替换为
            QD[k] = (this->*kernel_function)(k,k)+0.5/C;  // eL2LOSS replaced

C. 在 [class SVR_Q: public Kernel] 的 [public:] 的 [Qfloat *get_Q] 中, 在
            for(j=0;j<l;j++)
                data[j] = (Qfloat)(this->*kernel_function)(real_i,j);
之后增加
            data[real_i] += 0.5/C;  // eL2LOSS added
(与for的缩进相同)

D. 在 [class SVR_Q: public Kernel] 的 [private:] 中, 增加
    double C;  // eL2LOSS added

E. 在 [static void solve_epsilon_svr] 的 [Solver s;] 中, 将
    s.Solve(2*l, SVR_Q(*prob,*param), linear_term, y, // eL1LOSS
        alpha2, param->C, param->C, param->eps, si, param->shrinking); 
替换为
    s.Solve(2*l, SVR_Q(*prob,*param), linear_term, y, // eL2LOSS replaced 
        alpha2, INF, INF, param->eps, si, param->shrinking);

---------------------------------------------------------

3. 其他模型的修改方式类似

