# env-util
配置开发环境的小工具
ros_installer工具支持Noetic、Melodic、Kinetic版本的ros安装，安装过程会自动配置国内镜像源

示例：使用ros_installer安装ROS
```bash
curl -fsSL https://raw.githubusercontent.com/chinaheyu/env-util/master/ros_installer.sh|bash
```

注意：
- 设置Ubuntu镜像源与设置GitHub的hosts文件这两个python脚本需要管理员权限运行
- 修改hosts访问GitHub效果不是很好，谨慎使用
