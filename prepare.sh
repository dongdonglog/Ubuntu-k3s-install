#!/bin/bash

# 创建密钥
echo "正在创建密钥..."
if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "密钥对已经存在"
else
    ssh-keygen -f "$HOME/.ssh/id_rsa" -N '' > /tmp/create_ssh.log 2>&1
    echo "创建密钥完成"
fi

# 确保提供了包含凭据的文件作为参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <credentials_file>"
    exit 1
fi

CREDENTIALS_FILE=$1


# 检查文件是否存在
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Credentials file not found: $CREDENTIALS_FILE"
    exit 1
fi

# 安装sshpass
if ! command -v sshpass &> /dev/null; then
    echo "正在安装sshpass..."
    password=$(awk -F, 'NR==1 {print $2}' "$CREDENTIALS_FILE")
    echo $password | sudo -S apt update && sudo apt install sshpass -y
    # 确保 sshpass 已安装
    if ! command -v sshpass &> /dev/null; then
        echo "sshpass 安装失败，请检查并重试。"
        exit 1
    fi
fi


# 读取凭据文件并分发密钥
while IFS=',' read -r user pass ip; do
    # 检查字段数量
    if [ -z "$user" ] || [ -z "$pass" ] || [ -z "$ip" ]; then
        echo "格式错误：用户名、密码或 IP 地址不能为空。"
        continue
    fi
    echo "正在为 $ip 使用用户 $user 分发 SSH 密钥..."
    sshpass -p "$pass" ssh-copy-id -o StrictHostKeyChecking=no "$user@$ip" >> /tmp/create_ssh.log 2>&1
    if [ $? -eq 0 ]; then
        echo "密钥分发成功: $ip"
    else
        echo "密钥分发失败: $ip" >> /tmp/create_ssh.log
        echo "查看/tmp/create_ssh.log报错原因"
    fi
done < "$CREDENTIALS_FILE"

echo "SSH 密钥分发完成。"

# 安装ansible工具
if ! command -v ansible &> /dev/null; then
    echo "正在安装ansible工具..."
    password=$(awk -F, 'NR==1 {print $2}' "$CREDENTIALS_FILE")
    echo $password | sudo -S apt update && sudo apt install ansible -y
    # 确保 ansible 已安装
    if ! command -v ansible &> /dev/null; then
        echo "ansible 安装失败，请检查并重试。"
        exit 1
    fi
fi

echo "Ansible 安装完成。"
