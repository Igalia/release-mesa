#!/bin/bash

if test "x$DO_CLASSIC_BUILD" = xyes && test "x$IS_CLASSIC_BUILD" = xyes; then
  if test "x$BUILD" = xmake; then
    test -n "$OVERRIDE_CC" && export CC="$OVERRIDE_CC"
    test -n "$OVERRIDE_CXX" && export CXX="$OVERRIDE_CXX"
    test -n "$OVERRIDE_PATH" && export PATH="$OVERRIDE_PATH:$PATH"

    export CFLAGS="$CFLAGS -isystem`pwd`"

    ./autogen.sh --enable-debug \
      $LIBUNWIND_FLAGS \
      $DRI_LOADERS \
      --with-dri-drivers=$DRI_DRIVERS \
      $GALLIUM_ST \
      --with-gallium-drivers=$GALLIUM_DRIVERS \
      --with-vulkan-drivers=$VULKAN_DRIVERS \
      --disable-llvm-shared-libs \
    && make && eval $MAKE_CHECK_COMMAND
  elif test "x$BUILD" = xscons; then
    test -n "$OVERRIDE_CC" && export CC="$OVERRIDE_CC"
    test -n "$OVERRIDE_CXX" && export CXX="$OVERRIDE_CXX"
    scons $SCONS_TARGET && eval $SCONS_CHECK_COMMAND
  elif test "x$BUILD" = xmeson; then
    export CFLAGS="$CFLAGS -isystem`pwd`"
    meson _build $MESON_OPTIONS
    ninja -C _build
  fi
fi
