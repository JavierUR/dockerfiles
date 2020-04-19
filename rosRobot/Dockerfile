FROM osrf/ros:melodic-desktop-full

RUN apt update \
    && apt upgrade -y \
    && apt install -y python-pip terminator mesa-utils pulseaudio bash-completion \
    && apt install -y ros-melodic-sound-play \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install --no-cache-dir --upgrade numpy future torch torchvision pillow cython

RUN sed -i "$ a source /opt/ros/melodic/setup.bash" /etc/bash.bashrc
