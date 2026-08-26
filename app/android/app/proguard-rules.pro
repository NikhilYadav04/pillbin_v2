# uCrop (via image_cropper) can load images over the network with OkHttp, but
# that dependency is optional and PillBin only ever crops local files. R8 sees
# the unreachable references and fails the release build, so silence them.
-dontwarn okhttp3.**
-dontwarn okio.**
