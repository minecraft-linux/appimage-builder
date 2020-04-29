#include <curl/curl.h>
#include <cstdlib>
#include <sstream>
static inline CURL * __curl_easy_init() {
    CURL * curl = curl_easy_init();
    const char* appdir = getenv("APPDIR");
    if (appdir) {
        std::ostringstream cacert;
        cacert << appdir << "/usr/share/mcpelauncher/cacert.pem";
        curl_easy_setopt(curl, CURLOPT_CAINFO, cacert.str().data());
    }
    return curl;
}
#define curl_easy_init() __curl_easy_init()