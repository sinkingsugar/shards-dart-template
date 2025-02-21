#!/bin/bash

# Exit on any error
set -e

# Set default build type
BUILD_TYPE=${1:-RelWithDebInfo}

# Run from shards folder!!
CURRENT_PATH=$(pwd)
cd ${SHARDS_PATH}/../../

# # visionOS build
# cmake -Bbuild_visionos_${BUILD_TYPE}_frmwk -GXcode \
#     -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
#     -DCMAKE_SYSTEM_NAME=visionOS \
#     -DCMAKE_SYSTEM_PROCESSOR=arm64 \
#     -DXCODE_SDK=xros \
#     -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=7Q267P2WJ3 \
#     -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_STYLE=Automatic \
#     -DSHARDS_LOG_ROTATING_MAX_FILE_SIZE=5000000 \
#     -DSHARDS_LOG_ROTATING_MAX_FILES=3 \
#     -DDISABLE_CANDLE_METAL=ON
# cd build_visionos_${BUILD_TYPE}_frmwk
# xcodebuild -scheme shards-framework -configuration ${BUILD_TYPE} \
#     -destination "generic/platform=visionOS" \
#     build
# cd ../

# # iOS device build
# cmake -Bbuild_ios_${BUILD_TYPE}_frmwk -GXcode \
#     -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
#     -DCMAKE_SYSTEM_NAME=iOS \
#     -DCMAKE_SYSTEM_PROCESSOR=arm64 \
#     -DXCODE_SDK=iphoneos \
#     -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=7Q267P2WJ3 \
#     -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_STYLE=Automatic \
#     -DSHARDS_LOG_ROTATING_MAX_FILE_SIZE=5000000 \
#     -DSHARDS_LOG_ROTATING_MAX_FILES=3 \
#     -DDISABLE_CANDLE_METAL=ON
# cd build_ios_${BUILD_TYPE}_frmwk
# xcodebuild -scheme shards-framework -configuration ${BUILD_TYPE} \
#     -destination "generic/platform=iOS" \
#     build
# cd ../

# # iOS Simulator build
# cmake -Bbuild_iossim_${BUILD_TYPE}_frmwk -GXcode \
#     -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
#     -DCMAKE_SYSTEM_NAME=iOS \
#     -DCMAKE_SYSTEM_PROCESSOR=arm64 \
#     -DXCODE_SDK=iphonesimulator \
#     -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=7Q267P2WJ3 \
#     -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_STYLE=Automatic \
#     -DSHARDS_LOG_ROTATING_MAX_FILE_SIZE=5000000 \
#     -DSHARDS_LOG_ROTATING_MAX_FILES=3 \
#     -DDISABLE_CANDLE_METAL=ON
# cd build_iossim_${BUILD_TYPE}_frmwk
# xcodebuild -scheme shards-framework -configuration ${BUILD_TYPE} \
#     -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2" \
#     ARCHS=arm64 ONLY_ACTIVE_ARCH=YES \
#     build
# cd ../

# macOS build
cmake -Bbuild_macos_${BUILD_TYPE}_frmwk -GXcode \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_SYSTEM_NAME=Darwin \
    -DCMAKE_SYSTEM_PROCESSOR=arm64 \
    -DXCODE_SDK=macosx \
    -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=7Q267P2WJ3 \
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_STYLE=Automatic \
    -DSHARDS_LOG_ROTATING_MAX_FILE_SIZE=5000000 \
    -DSHARDS_LOG_ROTATING_MAX_FILES=3 \
    -DDISABLE_CANDLE_METAL=ON
cd build_macos_${BUILD_TYPE}_frmwk
xcodebuild -scheme shards-framework -configuration ${BUILD_TYPE} \
    -destination "generic/platform=macOS" \
    build
cd ../

rm -rf $CURRENT_PATH/Shards.xcframework

# xcodebuild -create-xcframework \
#   -framework "$(pwd)/build_visionos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework" \
#   -debug-symbols "$(pwd)/build_visionos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework.dSYM" \
#   -framework "$(pwd)/build_ios_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework" \
#   -debug-symbols "$(pwd)/build_ios_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework.dSYM" \
#   -framework "$(pwd)/build_iossim_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework" \
#   -debug-symbols "$(pwd)/build_iossim_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework.dSYM" \
#   -framework "$(pwd)/build_macos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework" \
#   -debug-symbols "$(pwd)/build_macos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework.dSYM" \
#   -output $CURRENT_PATH/Shards.xcframework

xcodebuild -create-xcframework \
  -framework "$(pwd)/build_macos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework" \
  -debug-symbols "$(pwd)/build_macos_${BUILD_TYPE}_frmwk/lib/${BUILD_TYPE}/Shards.framework.dSYM" \
  -output $CURRENT_PATH/Shards.xcframework
