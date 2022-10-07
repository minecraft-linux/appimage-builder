CFLAGS32="-I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib $CFLAGS32"
CFLAGS="-I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib $CFLAGS"
CXXFLAGS32="-stdlib=libc++ $CXXFLAGS32"
CXXFLAGS="-stdlib=libc++ $CXXFLAGS"