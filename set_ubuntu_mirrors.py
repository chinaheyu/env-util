#! /usr/bin/env python3

import os
import re
import requests
import sys

def set_ubuntu_mirrors():
    with os.popen('lsb_release -sc','r') as f:
        code_name = f.read().rstrip('\n')
    print(f'Ubuntu Codename: {code_name}')

    print('Getting sources list ...')
    response = requests.get('https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/')
    mirrors = re.search('<script id="apt-template" type="x-tmpl-markup">(.*?)</script>',response.content.decode('utf-8'),re.DOTALL)[1]
    mirrors = mirrors.replace('{{release_name}}',code_name)

    print('Writing sources list ...')
    with open('/etc/apt/sources.list','w') as f:
        f.write(mirrors)

    print('update sources list ...')
    os.system('apt update >> /dev/null')

    print('finished!')

if __name__ == '__main__':
    if os.geteuid():
        print('Please enter your passwords to get root privilege ...')
        args = [sys.executable] + sys.argv
        os.execlp('sudo', 'sudo', *args)
    set_ubuntu_mirrors()
