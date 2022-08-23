FROM tiryoh/ubuntu-desktop-lxde-vnc:jammy

LABEL maintainer="ngwk@utar.edu.my"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -q && \ 
    apt upgrade -yq

RUN apt update -q && apt install locales -yq
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN apt install software-properties-common -yq
RUN add-apt-repository universe

RUN apt update -q && apt install curl gnupg lsb-release -yq
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

RUN apt update -q && \ 
    apt upgrade -yq

RUN apt update -q && apt install git -yq
RUN apt update -q && apt install ros-humble-desktop -yq
RUN apt update -q && apt install ignition-fortress -yq
RUN apt update -q && apt install python3-colcon-common-extensions -yq
RUN apt update -q && apt install \ 
    ros-humble-turtlesim ros-humble-slam-toolbox \
    ros-humble-navigation2 ros-humble-nav2-bringup \
    ros-humble-ros-ign ros-humble-teleop-twist-keyboard \ 
    ros-humble-robot-localization -yq

RUN apt clean autoclean &&\
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
    echo ubuntu:ubuntu | chpasswd && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN gosu ubuntu rosdep update && \
    grep -F "source /opt/ros/humble/setup.bash" /home/ubuntu/.bashrc || echo "source /opt/ros/humble/setup.bash" >> /home/ubuntu/.bashrc && \
    sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc

RUN mkdir -p ~/ros2_ws/src
RUN cd ~/ros2_ws && colcon build --symlink-install

ENV USER ubuntu