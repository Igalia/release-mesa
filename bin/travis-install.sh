#!/bin/bash

set -ev

if test "x$DO_CLASSIC_BUILD" = xyes && test "x$IS_CLASSIC_BUILD" = xyes; then
  pip install --user mako

  # Install the latest meson from pip, since the version in the ubuntu repos is
  # often quite old.
  if test "x$BUILD" = xmeson; then
    pip3 install --user meson
  fi

  # Since libdrm gets updated in configure.ac regularly, try to pick up the
  # latest version from there.
  for line in `grep "^LIBDRM.*_REQUIRED=" configure.ac`; do
    old_ver=`echo $LIBDRM_VERSION | sed 's/libdrm-//'`
    new_ver=`echo $line | sed 's/.*REQUIRED=//'`
    if `echo "$old_ver,$new_ver" | tr ',' '\n' | sort -Vc 2> /dev/null`; then
      export LIBDRM_VERSION="libdrm-$new_ver"
    fi
  done

  # Install dependencies where we require specific versions (or where
  # disallowed by Travis CI's package whitelisting).

  wget $XORG_RELEASES/util/$XORGMACROS_VERSION.tar.bz2
  tar -jxvf $XORGMACROS_VERSION.tar.bz2
  (cd $XORGMACROS_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget $XORG_RELEASES/proto/$GLPROTO_VERSION.tar.bz2
  tar -jxvf $GLPROTO_VERSION.tar.bz2
  (cd $GLPROTO_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget $XORG_RELEASES/proto/$DRI2PROTO_VERSION.tar.bz2
  tar -jxvf $DRI2PROTO_VERSION.tar.bz2
  (cd $DRI2PROTO_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget $XCB_RELEASES/$XCBPROTO_VERSION.tar.bz2
  tar -jxvf $XCBPROTO_VERSION.tar.bz2
  (cd $XCBPROTO_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget $XCB_RELEASES/$LIBXCB_VERSION.tar.bz2
  tar -jxvf $LIBXCB_VERSION.tar.bz2
  (cd $LIBXCB_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget $XORG_RELEASES/lib/$LIBPCIACCESS_VERSION.tar.bz2
  tar -jxvf $LIBPCIACCESS_VERSION.tar.bz2
  (cd $LIBPCIACCESS_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget http://dri.freedesktop.org/libdrm/$LIBDRM_VERSION.tar.bz2
  tar -jxvf $LIBDRM_VERSION.tar.bz2
  (cd $LIBDRM_VERSION && ./configure --prefix=$HOME/prefix --enable-vc4 --enable-freedreno --enable-etnaviv-experimental-api && make install)

  wget $XORG_RELEASES/lib/$LIBXSHMFENCE_VERSION.tar.bz2
  tar -jxvf $LIBXSHMFENCE_VERSION.tar.bz2
  (cd $LIBXSHMFENCE_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget http://people.freedesktop.org/~aplattner/vdpau/$LIBVDPAU_VERSION.tar.bz2
  tar -jxvf $LIBVDPAU_VERSION.tar.bz2
  (cd $LIBVDPAU_VERSION && ./configure --prefix=$HOME/prefix && make install)

  wget http://www.freedesktop.org/software/vaapi/releases/libva/$LIBVA_VERSION.tar.bz2
  tar -jxvf $LIBVA_VERSION.tar.bz2
  (cd $LIBVA_VERSION && ./configure --prefix=$HOME/prefix --disable-wayland --disable-dummy-driver && make install)

  wget $WAYLAND_RELEASES/$LIBWAYLAND_VERSION.tar.xz
  tar -axvf $LIBWAYLAND_VERSION.tar.xz
  (cd $LIBWAYLAND_VERSION && ./configure --prefix=$HOME/prefix --enable-libraries --without-host-scanner --disable-documentation --disable-dtd-validation && make install)

  wget $WAYLAND_RELEASES/$WAYLAND_PROTOCOLS_VERSION.tar.xz
  tar -axvf $WAYLAND_PROTOCOLS_VERSION.tar.xz
  (cd $WAYLAND_PROTOCOLS_VERSION && ./configure --prefix=$HOME/prefix && make install)

  # Meson requires ninja >= 1.6, but trusty has 1.3.x
  wget https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-linux.zip
  unzip ninja-linux.zip
  mv ninja $HOME/prefix/bin/

  # Generate the header since one is missing on the Travis instance
  mkdir -p linux
  printf "%s\n" \
         "#ifndef _LINUX_MEMFD_H" \
         "#define _LINUX_MEMFD_H" \
         "" \
         "#define __NR_memfd_create 319" \
         "#define SYS_memfd_create __NR_memfd_create" \
         "" \
         "#define MFD_CLOEXEC             0x0001U" \
         "#define MFD_ALLOW_SEALING       0x0002U" \
         "" \
         "#endif /* _LINUX_MEMFD_H */" > linux/memfd.h
fi
