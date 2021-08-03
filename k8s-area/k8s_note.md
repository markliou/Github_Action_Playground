K8s使用紀錄
===
紀錄一些使用K8s會使用到的指令與用法。
# Install
安裝部分大概分為兩大項，如果機器夠多可以直接使用K8s，這當中就需要安排master與slave。如果是單純要測試是否yaml可以順利運作，就在單機上安裝minikube就能直接測試yaml運作狀況。
## [K8s](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
主要分為master跟slave。在這兩種節點上都需要安裝3個基礎工具:
1.kubeadm : 管理節點與節點間的關係。不同節點上都會有各自的k8s daemon，靠這工具來操作的些daemon的連接關係。
2.kubelet : 在節點上運作K8s的基本功能。例如建構k8s的daemon。
3.kubectl : 控制k8s的行為，如需要建構pod或是Deploy服務等等。
### Step 0. 調整網路以及安裝docker
```shell
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```
k8s會建構複雜服務，所以在[手動檢查一下有沒有其他服務佔據了port](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)。[完畢以後也檢查有沒有安裝docker](https://docs.docker.com/engine/install/ubuntu/)。
如果使用docker，也要一併處理[docker-shim的問題](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)。

### step 1.安裝工具集
```shell=
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```
k8s有個很麻煩的地方，就是在master上跟slave上的版本必須一致。所以最好一次把所有節點都設定完畢。如果事後才加入新的節點有很大的機會會全部掛掉，而且即使用"kubeadm reset"也救不起來。因此這邊就把k8s的工具都先鎖定不要更新。
```shell
sudo apt-mark hold kubelet kubeadm kubectl
```
### Step 2.啟用k8s
k8s分為mater節點與slave節點。會需要跑initial的只有master節點。因此先在決定要跑
master的節點上下達:
```shell
sudo kubeadm init
```
接下來就會出現一些指令，嘗試過使用普通user來啟動kubeadm，但下場都不是很好。所以假設現在的使用者都是root。
```shell
  export KUBECONFIG=/etc/kubernetes/admin.conf
```
再往下有長這樣的
```shell
kubeadm join 192.168.xxx.xxx:6443 --token xxxxxx.2vi8w45bma0hxwl8 \
        --discovery-token-ca-cert-hash sha256:xxxxxe6833e78c47e01xxxxx80979350d9949bfcxxxxx2xxxxx84xxxxxb39a42
```
把上面那一行直接讓slave執行即可。*記得slave也要把上面的3個工具也裝齊*。然後就能在主節點上測試:
```shell
kubectl get nodes
```
### 額外使用指令
* kubeadm reset : 如果不小心裝壞了(例如在slave上面跑kubeadm init)，有可能會讓其他東西執行不起來。這時就把kubeadm reset，就可以把之前的設定檔都清掉。

## minikube
minikube的安裝很簡單。可直接參考[這裡](https://minikube.sigs.k8s.io/docs/start/)。

# deployment
