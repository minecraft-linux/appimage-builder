#define gettid() 0
#define KeyCode __X11_KeyCode
#include <EGL/egl.h>
#undef KeyCode
#ifdef Success
#undef Success
#endif
#ifdef Retry
#undef Retry
#endif
#ifdef Abort
#undef Abort
#endif