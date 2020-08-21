echo "install python3-pip ..."
sudo apt -y install python3-pip > /dev/null 2>&1
echo "update pip3 ..."
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U > /dev/null 2>&1
echo "set mirrors ..."
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple > /dev/null 2>&1
echo "finished"
