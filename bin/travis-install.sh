#!/bin/bash

set -ev

if test "x$DO_CLASSIC_BUILD" = xyes && test "x$IS_CLASSIC_BUILD" = xyes; then
  pip install --user mako

  # Since libdrm gets updated in configure.ac regularly, try to pick up the
  # latest version from there.
  for line in `grep "^LIBDRM.*_REQUIRED=" configure.ac`; do
    old_ver=`echo $LIBDRM_VERSION | sed 's/libdrm-//'`;
    new_ver=`echo $line | sed 's/.*REQUIRED=//'`;
    if `echo "$old_ver,$new_ver" | tr ',' '\n' | sort -Vc 2> /dev/null`; then
      export LIBDRM_VERSION="libdrm-$new_ver";
    fi;
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

  # libtxc-dxtn uses the patented S3 Texture Compression
  # algorithm. Therefore, we don't want to use this library but it is
  # still possible through setting the USE_TXC_DXTN variable to yes in
  # the travis web UI.
  #
  # According to Wikipedia, the patent expires on October 2, 2017:
  # https://en.wikipedia.org/wiki/S3_Texture_Compression#Patent
  if test "x$USE_TXC_DXTN" = xyes; then
    wget https://people.freedesktop.org/~cbrill/libtxc_dxtn/$LIBTXC_DXTN_VERSION.tar.bz2;
    tar -jxvf $LIBTXC_DXTN_VERSION.tar.bz2;
    (cd $LIBTXC_DXTN_VERSION && ./configure --prefix=$HOME/prefix && make install);
  fi

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
