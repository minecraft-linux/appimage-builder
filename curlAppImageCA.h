#include <sstream>
template<class T, class C, class O, T*(*curl_easy_init)(), O CURLOPT_CAINFO, C(*curl_easy_setopt)(T *handle, O option, ...)> inline T* __curl_easy_init() {
    T* curl = curl_easy_init();
    const char* appdir = getenv("APPDIR");
    if (appdir) {
        std::ostringstream cacert;
        cacert << appdir << "/usr/share/mcpelauncher/cacert.pem";
        curl_easy_setopt(curl, CURLOPT_CAINFO, cacert.str().data());
    }
    return curl;
}
#define curl_easy_init() __curl_easy_init<CURL, CURLcode, curl_easy_init, curl_easy_setopt, CURLOPT_CAINFO, curl_easy_setopt>()