#!/bin/bash
# Script of ROS2 Dashing Debian Source Install Setup
# Steps from https://index.ros.org/doc/ros2/Installation/Dashing/Linux-Development-Setup/
# Tested on Ubuntu 18.04

echo "Starting ROS2 Dashing Setup"
echo "(Steps from https://index.ros.org/doc/ros2/Installation/Dashing/Linux-Development-Setup/)"

# Setup Locale
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Setup Sources
sudo apt update && sudo apt install curl gnupg2 lsb-release
curl http://repo.ros2.org/repos.key | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install ROS2 Dashing apt packages
sudo apt update
sudo apt install ros-dashing-desktop

# Install Development Tools and ROS tools
sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-lark-parser \
  python3-lxml \
  python3-numpy \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  wget

python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  pytest-cov \
  pytest-runner \
  setuptools

sudo apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev

# Get ROS2 Dashing Code
mkdir -p ~/ros2_ws_dashing/src
cd ~/ros2_ws_dashing
wget https://raw.githubusercontent.com/ros2/ros2/release-latest/ros2.repos
vcs import src < ros2.repos

# Install dependencies using rosdep
sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro dashing -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers"

# Install more DDS implementations
sudo apt install libopensplice69  # from packages.ros.org/ros2/ubuntu
sudo apt install -q --yes --force-yes \
    rti-connext-dds-5.3.1  # from packages.ros.org/ros2/ubuntu
cd /opt/rti.com/rti_connext_dds-5.3.1/resource/scripts && source ./rtisetenv_x64Linux3gcc5.4.0.bash; cd -

# Build the workspace
touch ~/ros2_ws_dashing/src/ros2/system_tests/test_cli/AMENT_IGNORE
cd ~/ros2_ws_dashing/
colcon build --symlink-install

# Done
echo "ROS2 Dashing Setup is done."
echo "You can now test your environment with:"
echo ". install/local_setup.bash"
echo "ros2 run demo_nodes_cpp talker"
echo "and in another Tab:"
echo "ros2 run demo_nodes_py listener"
