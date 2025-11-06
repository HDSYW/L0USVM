/* --------------------------------------------------------------------
 求核函数lin, poly, rbf的值

-------------------------------------------------------------------- */

#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <string.h>

/* --- 全部的变量 --------------------------------------------- */

double *dataA;      /* 指向第一个数据样本的指针 */
double *dataB;      /* 指向第二个数据样本的指针 */
long dim;           /* 样本的维数*/
int ker;            /* 核函数的编号(0 - lin, 1 - poly, 2 - rbf, 3 - sigmoid */
double *arg1;       /* 核函数的变量 */
long ker_cnt;       /* 计算出来的核函数的值 */

char *kernel_name[] = {"lin","poly","rbf","sigmoid"};

/* -------------------------------------------------------------------
 计算a，b向量的点积
 c = a'*b
------------------------------------------------------------------- */
double dot_prod( long a, long b)
{
   double c = 0;
   long i;
   for( i = 0; i < dim; i++ ) {
      c += *(dataA+(a*dim)+i) * *(dataB+(b*dim)+i);
   }
   return( c );
}

/* -------------------------------------------------------------------
 计算(a-b)'，(a-b)的点积
 c = (a-b)'*(a-b)
------------------------------------------------------------------- */
double sub_dot_prod( long a, long b )
{
   double c = 0;
   long i;
   for( i = 0; i < dim; i++ ) {
      c += (*(dataA+(a*dim)+i) - *(dataB+(b*dim)+i))*
           (*(dataA+(a*dim)+i) - *(dataB+(b*dim)+i));
   }
   return( c );
}

/* --------------------------------------------------------------------
 将核函数从字符串类型转化为int型
-------------------------------------------------------------------- */
int kernel_id( const mxArray *prhs1 )
{
  int num, i, buf_len;
  char *buf;

  if( mxIsChar( prhs1 ) != 1) return( -1 );

  buf_len  = (mxGetM(prhs1) * mxGetN(prhs1)) + 1;
  buf = mxCalloc( buf_len, sizeof( char ));

  mxGetString( prhs1, buf, buf_len );
  
  num = sizeof( kernel_name )/sizeof( char * );

  for( i = 0; i < num; i++ ) {
    if( strcmp( buf, kernel_name[i] )==0 ) return( i );
  }

  return(-1);
}

/* --------------------------------------------------------------------
 计算核函数
 第一个变量的地址是dataA ，第二个变量的地址是dataB
-------------------------------------------------------------------- */
double kernel( long a, long b )
{
   double c = 0;

   ker_cnt++;

   switch( ker ) {
      /* 线性核函数 */
      case 0:
         c = dot_prod( a, b );
         break;
      /* 多项式核函数 */
      case 1:
         c = pow( (dot_prod( a, b) + arg1[1]), arg1[0] );
         break;
      /* 径向基核函数（radial basis functions kernel）*/
      case 2:
         c = exp( -0.5*sub_dot_prod( a, b)/(arg1[0]*arg1[0]) );
         break;
      default:
         c = 0;
   }
   return( c );
}

