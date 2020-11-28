#!/bin/sh
set -e
 
# We will recreate those
rm -rf include/*.h
rm -rf *.a
rm -rf build/
make distclean

# The build for Apple Silicon M1 and get silicon.a
make platform=silicon
cp -r silicon/include/*.h include
cp -r silicon/include/*.a .
libtool -static -o silicon.a libjpeg.a liblept.a libpng.a libtiff.a libtesseract.a

# First build for intel and get macos.a
make platform=macos
cp -r macos/include/*.h include
cp -r macos/include/*.a .
libtool -static -o macos.a libjpeg.a liblept.a libpng.a libtiff.a libtesseract.a

# There is an issue with the macro expansion for fract1 on macOS that causes the xcframework to not be useable
sed -ie 's/.*fract1.*//' include/allheaders.h

# The builds for both chips need to be bundled, Xcode expects that for the macOS project
lipo -create -output combined.a macos.a silicon.a

# We create the regular framework using the Xcode project template
xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract macOS' \
  -sdk macosx \
  -destination 'platform=OS X' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

# And then stuff it all into a single xcframework, such Xcode can pick whatever it needs 
xcodebuild -create-xcframework \
  -framework 'build/Release/libtesseract.framework' \
  -output 'build/libtesseract.xcframework'
