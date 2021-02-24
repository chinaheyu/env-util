#!/usr/bin/env python3

import re
from collections import Counter
from retry import retry
import requests
import platform

RAW_URL = [
    "github.githubassets.com",
    "camo.githubusercontent.com",
    "github.map.fastly.net",
    "github.global.ssl.fastly.net",
    "gist.github.com",
    "github.io",
    "github.com",
    "api.github.com",
    "raw.githubusercontent.com",
    "user-images.githubusercontent.com",
    "favicons.githubusercontent.com",
    "avatars5.githubusercontent.com",
    "avatars4.githubusercontent.com",
    "avatars3.githubusercontent.com",
    "avatars2.githubusercontent.com",
    "avatars1.githubusercontent.com",
    "avatars0.githubusercontent.com"]
IPADDRESS_PREFIX = ".ipaddress.com"

HOSTS_TEMPLATE = "\n# GitHub520 Host Start\n{content}# GitHub520 Host End\n"

def make_ipaddress_url(raw_url: str):
    dot_count = raw_url.count(".")
    if dot_count > 1:
        raw_url_list = raw_url.split(".")
        tmp_url = raw_url_list[-2] + "." + raw_url_list[-1]
        ipaddress_url = "https://" + tmp_url + IPADDRESS_PREFIX + "/" + raw_url
    else:
        ipaddress_url = "https://" + raw_url + IPADDRESS_PREFIX
    return ipaddress_url


@retry(tries=3)
def get_ip(session: requests.session, raw_url: str):
    url = make_ipaddress_url(raw_url)
    try:
        rs = session.get(url, timeout=5)
        pattern = r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"
        ip_list = re.findall(pattern, rs.text)
        ip_counter_obj = Counter(ip_list).most_common(1)
        if ip_counter_obj:
            return raw_url, ip_counter_obj[0][0]
        raise Exception("ip address empty")
    except Exception as ex:
        print("get: {}, error: {}".format(url, ex))
        raise Exception


def main():
    session = requests.session()
    content = ""
    for raw_url in RAW_URL:
        try:
            host_name, ip = get_ip(session, raw_url)
            content += ip.ljust(30) + host_name + "\n"
        except Exception:
            continue
    if not content:
        return
    hosts_content = HOSTS_TEMPLATE.format(content=content)
    print(hosts_content)
    hosts_path = ''
    if system_name:=platform.system() == 'Windows':
        hosts_path = r'C:\Windows\System32\drivers\etc\hosts'
    elif system_name == 'Linux':
        hosts_path = '/etc/hosts'
    else:
        print('System not supported')
        return
    try:
        with open(hosts_path,'a') as fp:
            fp.write(hosts_content)
            print('hosts修改成功')
    except PermissionError:
        print('hosts修改失败，没有管理员权限(PermissionError)')
    except Exception as e:
        print("error: {}".format(e))

if __name__ == '__main__':
    main()