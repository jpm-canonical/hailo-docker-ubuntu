# Define the tagged versions to checkout from Github
ARG TAPPAS_VERSION="v3.29.0"
ARG HAILORT_VERSION="v4.18.0"

FROM ubuntu:24.04

WORKDIR /root

RUN apt-get update && apt-get install -y software-properties-common sudo pkg-config gcc-9 g++-9
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install -y python3.11 python3.11-venv python3.11-dev

# Change default python to 3.11
RUN rm -f /usr/bin/python && ln -s /usr/bin/python3.11 /usr/bin/python
RUN rm -f /usr/bin/python3 && ln -s /usr/bin/python3.11 /usr/bin/python3

# Tappas deps
RUN apt-get install -y rsync ffmpeg x11-utils python3-dev python3-pip python3-setuptools python3-virtualenv python-gi-dev libgirepository1.0-dev gcc-12 g++-12 cmake git libzmq3-dev
# OpenCV
RUN apt-get install -y libopencv-dev python3-opencv
# Gstreamer
RUN apt-get install -y libcairo2-dev libgirepository1.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio gcc-12 g++-12 python-gi-dev
# PyGObject
RUN apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0

# Get Tappas source
RUN apt-get install -y git
RUN git clone https://github.com/hailo-ai/tappas.git
RUN cd tappas && git checkout ${TAPPAS_VERSION}

# Get Hailort source
RUN mkdir -p tappas/hailort
RUN git clone https://github.com/hailo-ai/hailort.git tappas/hailort/sources
RUN cd tappas/hailort/sources && git checkout ${HAILORT_VERSION}

# Get RPi 5 examples
RUN git clone --depth 1 https://github.com/raspberrypi/rpicam-apps.git

# Compile Hailort from source according to https://hailo.ai/developer-zone/documentation/hailort-v4-18-0/?sp_referrer=install/install.html#compiling-hailort-from-sources
RUN cd tappas/hailort/sources && cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DHAILO_BUILD_EXAMPLES=1 && sudo cmake --build build --config release --target install

# Compile Tappas from source according to https://github.com/hailo-ai/tappas/blob/master/docs/installation/manual-install.rst
RUN cd tappas && ./install.sh --skip-hailort --target-platform rpi
