/* --------------------------------------------------------------------

 kernel.c: 是MEX文件，用来计算核函数的值
 说明:
  K = kernel( data, ker, arg )
    data [dim x n1] ... 输入的数据向量
    ker [string] ... 识别核函数(具体见 kernel_fun.c)
    arg [1 x nargarg] ... 核函数变量

    K [n1 x n1] ... 核函数矩阵 K[i,j] = kernel(dataA(:,i),dataA(:,j));

  K = kernel( dataA, ker, arg, dataB )

    dataA [dim x n1] ... 矩阵 A.
    dataB [dim x n2] ... 矩阵 B.
    ker [string] ... 识别核函数(具体见 kernel_fun.c)
    arg [1 x nargarg] ... 核函数变量

    K [n1 x n2] ... 核函数矩阵 K[i,j] = kernel(dataA(:,i),dataB(:,j));

 -------------------------------------------------------------------- */

#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <stdlib.h>

#include "kernel_fun.h"

/* ==============================================================
 MEX 主函数，Matlab与其他应用程序的接口
============================================================== */
void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
   long i, j, n1, n2;
   double tmp;
   double *K;
  

   /* K = kernel( data, ker, arg ) */
   /* ------------------------------------------- */
   if( nrhs == 3) 
   {
      /* 数据矩阵 [dim x n1] */
      if( !mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) ||
        mxIsEmpty(prhs[0])    || mxIsComplex(prhs[0]) )
        mexErrMsgTxt("输入数据必须是一个实矩阵.");

      /* 识别核函数 */
      ker = kernel_id( prhs[1] );
      if( ker == -1 ) 
        mexErrMsgTxt("不合理的核函数标识.");
      
     /*  获取指向arguments 的指针 */
     arg1 = mxGetPr(prhs[2]);

     /* 获取指向输入数据向量的指针*/
     dataA = mxGetPr(prhs[0]);   
     dataB = dataA;
     dim = mxGetM(prhs[0]);      
     n1 = mxGetN(prhs[0]);       

     /* 创建输出核函数矩阵 */
     plhs[0] = mxCreateDoubleMatrix(n1,n1,mxREAL);
     K = mxGetPr(plhs[0]);
	 
     /* 计算核函数矩阵 */
     for( i = 0; i < n1; i++ ) {
        for( j = i; j < n1; j++ ) {
           tmp = kernel( i, j );
           K[i*n1+j] = tmp; 
           K[j*n1+i] = tmp; /* 核函数矩阵是对称的 */
        }
     }
   } 
   /* K = kernel( dataA, ker, arg, dataB ) */
   /* ------------------------------------------- */
   else if( nrhs == 4)
   {
      /*数据矩阵[dim x n1 ] */
      if( !mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) ||
        mxIsEmpty(prhs[0])    || mxIsComplex(prhs[0]) )
        mexErrMsgTxt("输入数据dataA必须是实矩阵.");

      /* 数据矩阵 [dim x n2 ] */
      if( !mxIsNumeric(prhs[3]) || !mxIsDouble(prhs[3]) ||
        mxIsEmpty(prhs[3])    || mxIsComplex(prhs[3]) )
        mexErrMsgTxt("输入数据dataB必须是实矩阵.");

      /* 识别核函数 */
      ker = kernel_id( prhs[1] );
      if( ker == -1 ) 
        mexErrMsgTxt("不合理的核函数标识.");

     /*  获取指向 arguments 的指针 */
     arg1 = mxGetPr(prhs[2]);

     /* 指向样本的指针*/
     dataA = mxGetPr(prhs[0]);    
     dataB = mxGetPr(prhs[3]);    
     dim = mxGetN(prhs[0]);       
     n1 = mxGetM(prhs[0]);        
     n2 = mxGetM(prhs[3]);        

     /* 创建输出核函数矩阵 */
     plhs[0] = mxCreateDoubleMatrix(n1,n2,mxREAL);
     K = mxGetPr(plhs[0]);
	 
     /* 计算核函数矩阵 */
     for( i = 0; i < n1; i++ ) {
        for( j = 0; j < n2; j++ ) {
           K[j*n1+i] = kernel( i, j );
        }
     }
   }
   else
   {
      mexErrMsgTxt("输入参数错误.");
   }

   return;
}
