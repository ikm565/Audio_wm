//
// MATLAB Compiler: 6.2 (R2016a)
// Date: Mon Mar 25 19:18:06 2019
// Arguments: "-B" "macro_default" "-W" "cpplib:watermark" "-T" "link:lib" "-d"
// "D:\GraduationDesign\≤‚ ‘\Matlab2Lib\embed\for_testing" "-v"
// "D:\GraduationDesign\≤‚ ‘\Matlab2Lib\compute.m"
// "D:\GraduationDesign\≤‚ ‘\Matlab2Lib\embed.m"
// "D:\GraduationDesign\≤‚ ‘\Matlab2Lib\extract.m" 
//

#ifndef __watermark_h
#define __watermark_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_watermark
#define PUBLIC_watermark_C_API __global
#else
#define PUBLIC_watermark_C_API /* No import statement needed. */
#endif

#define LIB_watermark_C_API PUBLIC_watermark_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_watermark
#define PUBLIC_watermark_C_API __declspec(dllexport)
#else
#define PUBLIC_watermark_C_API __declspec(dllimport)
#endif

#define LIB_watermark_C_API PUBLIC_watermark_C_API


#else

#define LIB_watermark_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_watermark_C_API 
#define LIB_watermark_C_API /* No special import/export declaration */
#endif

extern LIB_watermark_C_API 
bool MW_CALL_CONV watermarkInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_watermark_C_API 
bool MW_CALL_CONV watermarkInitialize(void);

extern LIB_watermark_C_API 
void MW_CALL_CONV watermarkTerminate(void);



extern LIB_watermark_C_API 
void MW_CALL_CONV watermarkPrintStackTrace(void);

extern LIB_watermark_C_API 
bool MW_CALL_CONV mlxCompute(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_watermark_C_API 
bool MW_CALL_CONV mlxEmbed(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_watermark_C_API 
bool MW_CALL_CONV mlxExtract(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_watermark
#define PUBLIC_watermark_CPP_API __declspec(dllexport)
#else
#define PUBLIC_watermark_CPP_API __declspec(dllimport)
#endif

#define LIB_watermark_CPP_API PUBLIC_watermark_CPP_API

#else

#if !defined(LIB_watermark_CPP_API)
#if defined(LIB_watermark_C_API)
#define LIB_watermark_CPP_API LIB_watermark_C_API
#else
#define LIB_watermark_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_watermark_CPP_API void MW_CALL_CONV compute(int nargout, mwArray& obj, const mwArray& in_audio, const mwArray& in_img, const mwArray& lambda);

extern LIB_watermark_CPP_API void MW_CALL_CONV embed(const mwArray& in_audio, const mwArray& out_audio, const mwArray& in_img, const mwArray& lambda);

extern LIB_watermark_CPP_API void MW_CALL_CONV extract(const mwArray& audio_input, const mwArray& ref_input, const mwArray& img_input, const mwArray& img_output, const mwArray& lambda);

#endif
#endif
