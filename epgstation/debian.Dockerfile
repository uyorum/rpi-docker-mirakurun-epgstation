FROM l3tnun/epgstation:master-debian

ENV DEV="make gcc git g++ automake curl wget sudo unzip cmake patch autoconf build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev"
ENV FFMPEG_VERSION=4.4.4
COPY ffmpeg.patch /tmp

# Path to OpenMAX hardware encoding libraries. They are part of Raspberry Pi firmware.
ENV LD_LIBRARY_PATH=/opt/vc/lib

RUN apt-get update && \
    apt-get -y install $DEV && \
    apt-get -y install yasm libx264-dev libmp3lame-dev libopus-dev libvpx-dev && \
    apt-get -y install libx265-dev libnuma-dev libomxil-bellagio-dev && \
    apt-get -y install libasound2 libass9 libvdpau1 libva-x11-2 libva-drm2 libxcb-shm0 libxcb-xfixes0 libxcb-shape0 libvorbisenc2 libtheora0 libaribb24-dev && \
    \
    # Install Raspberry Pi firmware
    cd /tmp && \
    wget https://github.com/raspberrypi/userland/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cd userland-master && \
    ./buildme && \
    test -d /opt/vc && \
    #ffmpeg build
    mkdir /tmp/ffmpeg_sources && \
    cd /tmp/ffmpeg_sources && \
    curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    patch -p1 < /tmp/ffmpeg.patch && \
    ./configure \
    --prefix=/usr/local \
    --disable-shared \
    --pkg-config-flags=--static \
    --cpu=armv7-a+fp \
    --enable-gpl \
    --enable-libass \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-omx \
    --enable-omx-rpi \
    --enable-version3 \
    --enable-libaribb24 \
    --enable-nonfree \
    --disable-debug \
    --disable-doc \
    && \
    make -j$(nproc) && \
    make install && \
    \
    # 不要なパッケージを削除
    SUDO_FORCE_REMOVE=yes apt-get -y remove $DEV && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
