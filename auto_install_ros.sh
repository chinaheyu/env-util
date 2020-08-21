#!/bin/bash

echo "    _         _          ___           _        _ _   ____   ___  ____  "
echo "   / \  _   _| |_ ___   |_ _|_ __  ___| |_ __ _| | | |  _ \ / _ \/ ___| "
echo "  / _ \| | | | __/ _ \   | || '_ \/ __| __/ _\` | | | | |_) | | | \___ \ "
echo " / ___ \ |_| | || (_) |  | || | | \__ \ || (_| | | | |  _ <| |_| |___) |"
echo '/_/   \_\__,_|\__\___/  |___|_| |_|___/\__\__,_|_|_| |_| \_\\___/|____/ '

code_name=$(lsb_release -sc)
echo "Ubuntu版本: $(lsb_release -ds)"
case $code_name in
    focal)
        ros_name=noetic
    ;;
    artful)
        ros_name=melodic
    ;;
    bionic)
        ros_name=melodic
    ;;
    xenial)
        ros_name=kinetic
    ;;
    wily)
        ros_name=kinetic
    ;;
    *)
        echo "暂不支持此版本的Ubuntu"
        exit
    ;;
esac
echo "对应的ros版本为${ros_name}"

echo "请选择你希望的安装方式："
echo "  1.桌面完整版：包含ROS、rqt、rviz、机器人通用库、2D/3D模拟器、导航以及2D/3D感知包"
echo "  2.桌面版：包含ROS、rqt、rviz和机器人通用库"
echo "  3.ROS-基础包：包含ROS包、构建和通信库，没有图形界面工具"
read -p "输入数字1-3：" opt
case $opt in
    1)
        ros_pack_opt="ros-${ros_name}-desktop-full"
    ;;
    2)
        ros_pack_opt="ros-${ros_name}-desktop"
    ;;
    3)
        ros_pack_opt="ros-${ros_name}-ros-base"
    ;;
    *)
        echo "请输入正确的数字"
        exit
    ;;
esac

echo "即将安装${ros_pack_opt}"

echo "正在设置Ubuntu镜像源..."
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo sh -c "echo \"# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释\" > /etc/apt/sources.list"
sudo sh -c "echo \"deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name} main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name} main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-updates main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-updates main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-backports main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-backports main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-security main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-security main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# 预发布软件源，不建议启用\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-proposed main restricted universe multiverse\" >> /etc/apt/sources.list"
sudo sh -c "echo \"# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${code_name}-proposed main restricted universe multiverse\" >> /etc/apt/sources.list"

echo "正在设置ROS镜像源..."
sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list'

echo "正在设置公钥..."
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 >> /dev/null

echo "正在更新软件包索引..."
sudo apt update >> /dev/null

echo "正在安装ROS(需要较长时间)..."
sudo apt -y install $ros_pack_opt >> ~/ros_install_log.txt

echo "正在设置环境..."
echo "source /opt/ros/${ros_name}/setup.bash" >> ~/.bashrc
source ~/.bashrc

if [ $ros_name = "noetic" ]
then
    echo "正在安装python3-rosdep..."
    sudo apt-get -y install python3-rosdep >> /dev/null
else
    echo "正在安装python-rosdep..."
    sudo apt-get -y install python-rosdep >> /dev/null
fi

echo "正在修改hosts..."
sudo sh -c 'echo "199.232.28.133 raw.githubusercontent.com" >> /etc/hosts'

echo "正在初始化rosdep..."
sudo rosdep init >> /dev/null
rosdep update >> /dev/null

echo "正在安装构建软件包的依赖..."
sudo apt-get -y install python-rosinstall python-rosinstall-generator python-wstool build-essential >> /dev/null

echo "已成功安装${ros_pack_opt}"

