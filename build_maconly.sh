#!/bin/sh
set -e
 
rm -rf include/*.h
rm -rf *.a
rm -rf build/

make distclean

make platform=macos
cp -r macos/include/*.h include
cp -r macos/include/*.a .
libtool -static -o macos.a libjpeg.a liblept.a libpng.a libtiff.a libtesseract.a

make platform=silicon
cp -r silicon/include/*.h include
cp -r silicon/include/*.a .
libtool -static -o silicon.a libjpeg.a liblept.a libpng.a libtiff.a libtesseract.a

# There is an issue with the macro expansion for fract1 on macOS that causes the xcframework to not be useable
sed -ie 's/.*fract1.*//' include/allheaders.h
 
lipo -create -output combined.a macos.a silicon.a

xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract macOS' \
  -sdk macosx \
  -destination 'platform=OS X' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

xcodebuild -create-xcframework \
  -framework 'build/Release/libtesseract.framework' \
  -output 'build/libtesseract.xcframework'
