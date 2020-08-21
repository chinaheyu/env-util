#!/bin/bash

echo -e "\033[33m==========================================="
echo " ____   ___  ____       _         _        "
echo "|  _ \ / _ \/ ___|     / \  _   _| |_ ___  "
echo "| |_) | | | \___ \    / _ \| | | | __/ _ \ "
echo "|  _ <| |_| |___) |  / ___ \ |_| | || (_) |"
echo '|_| \_\\___/|____/  /_/   \_\__,_|\__\___/ '
echo "                                           "
echo " ___           _        _ _           "
echo "|_ _|_ __  ___| |_ __ _| | | ___ _ __ "
echo " | || '_ \/ __| __/ _\` | | |/ _ \ '__|"
echo " | || | | \__ \ || (_| | | |  __/ |   "
echo "|___|_| |_|___/\__\__,_|_|_|\___|_|   "
echo "                                           "
echo -e "===========================================\033[0m"


code_name=$(lsb_release -sc)
echo -e "当前Ubuntu版本: \033[32m$(lsb_release -ds)\033[0m"
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
echo -e "对应的ros版本: \033[32m${ros_name}\033[0m"
echo "==========================================="
echo "                                           "
echo "请选择你希望的安装方式："
echo "  1.桌面完整版(建议)：包含ROS、rqt、rviz、机器人通用库、2D/3D模拟器、导航以及2D/3D感知包"
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

echo -e "\033[36m开始安装${ros_pack_opt}"

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
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 >> /dev/null 2>&1

echo "正在更新软件包索引..."
sudo apt update >> /dev/null 2>&1

echo "正在安装ROS(需要较长时间)..."
sudo apt -y install $ros_pack_opt >> ~/ros_install_log.txt 2>&1

echo "正在设置环境..."
echo "source /opt/ros/${ros_name}/setup.bash" >> ~/.bashrc
source ~/.bashrc

if [ $ros_name = "noetic" ]
then
    echo "正在安装python3-rosdep..."
    sudo apt-get -y install python3-rosdep >> /dev/null 2>&1
else
    echo "正在安装python-rosdep..."
    sudo apt-get -y install python-rosdep >> /dev/null 2>&1
fi

echo "正在修改hosts..."
sudo sh -c 'echo "199.232.28.133 raw.githubusercontent.com" >> /etc/hosts'

echo "正在初始化rosdep..."
sudo rosdep init >> /dev/null 2>&1
rosdep update >> /dev/null 2>&1

echo "正在安装构建软件包的依赖..."
sudo apt-get -y install python-rosinstall python-rosinstall-generator python-wstool build-essential >> /dev/null 2>&1

echo -e "已成功安装${ros_pack_opt}\033[0m"

