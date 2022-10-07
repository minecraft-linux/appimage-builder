#pragma once
#include_next <curl/curl.h>
#include <cstdlib>
#include <sstream>

static inline void __curl_appimage_ca(CURL *curl) {
    const char* appdir = getenv("APPDIR");
    if (appdir && !getenv("MCPELAUNCHER_NOCAINFO")) {
        std::ostringstream cacert;
        cacert << appdir << "/usr/share/mcpelauncher/cacert.pem";
        curl_easy_setopt(curl, CURLOPT_CAINFO, cacert.str().data());
    }
}
static inline CURL * __curl_easy_init() {
    CURL * curl = curl_easy_init();
    __curl_appimage_ca(curl);
    return curl;
}
static inline void __curl_easy_reset(CURL *curl) {
    curl_easy_reset(curl);
    __curl_appimage_ca(curl);
}

#define curl_easy_init() __curl_easy_init()
#define curl_easy_reset(curl) __curl_easy_reset(curl)