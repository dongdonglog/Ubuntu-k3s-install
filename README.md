# k3s-ansible-install-ubuntu

高可用或者单机ansible安装教程
### 架构为：containered+flannel+treafik

## <span style="color:red;">注意：请规划好服务器IP</span>

## 前提条件
去你需要的k3s版本下面目录下载镜像包和helm版本包丢到机器可以访问的仓库，修改k3s.yaml

## 第一步
修改user-passwd-ip.txt文件，第一行请填写工作的机器也就是即将部署的机器，格式为用户名,密码，ip，这边建议机器的密码都统一，不然后面运行不了ansible脚本
```
例子仅供参考
master-test02,123456,10.10.61.46
test,123456,10.10.63.222
test-01,123456,10.10.63.239
test-02,123456,10.10.62.103
```
修改完完毕后，执行以下命令
```
bash prepare.sh user-passwd-ip.txt
```

## 第二步
后面修改hosts文件,[master]是第一个server节点，[master-ext]是其他多主的节点，[works]是从节点，请替换工作的ip， ansible_ssh_user变量，后面需要填写用户名，如test，登陆服务器的用户名。
```
例子仅供参考
[master]
10.10.63.222 ansible_ssh_user=test

[master-ext]
10.10.61.46 ansible_ssh_user=test

[works]
10.10.63.239 ansible_ssh_user=test
10.10.62.103 ansible_ssh_user=test
```

## 第三步
运行ansible命令,ANSIBLE_BECOME_PASS变量后面是密码，请密码一定要统一。
大概运行时间：5分钟，如果多一个节点则多运行30秒左右。
```
ANSIBLE_BECOME_PASS=123456 ansible-playbook -i hosts k3s.yml --private-key ~/.ssh/id_rsa -v
```

## 第四步
校验,在其中一台master机器上运行
```
kubectl get nodes

返回如下即是正确，STATUS字段下面都是Ready。
例子仅供参考：
kubectl  get nodes
NAME            STATUS   ROLES                       AGE   VERSION
master-test02   Ready    control-plane,etcd,master   24m   v1.27.4+k3s1
test            Ready    control-plane,etcd,master   23m   v1.27.4+k3s1
test-02         Ready    <none>                      21m   v1.27.4+k3s1

```

## 另外
项目中有longhorn高可用存储部署方式，请运行完上以上的操作才可以运行
```
ANSIBLE_BECOME_PASS=123456 ansible-playbook -i hosts longhorn-ansible.yml --private-key ~/.ssh/id_rsa -v
```
