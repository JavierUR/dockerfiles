FROM osrf/ros:melodic-desktop-full

RUN apt update \
    && apt upgrade -y \
    && apt install -y python-pip terminator mesa-utils \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install --no-cache-dir --upgrade numpy future torch torchvision pillow cython
