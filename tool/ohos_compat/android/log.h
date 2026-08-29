#ifndef BETTBOX_OHOS_ANDROID_LOG_H_
#define BETTBOX_OHOS_ANDROID_LOG_H_

#include <stdarg.h>
#include <stdio.h>

#define ANDROID_LOG_FATAL 7

static inline int __android_log_vprint(
    int priority,
    const char *tag,
    const char *format,
    va_list args) {
  (void)priority;
  fprintf(stderr, "%s: ", tag);
  return vfprintf(stderr, format, args);
}

#endif
