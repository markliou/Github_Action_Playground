Github_Action_Playground
==
Github action 透過修改 .github/workflow/ 的 yml檔案進行CI/CD。目前已經支援建構 self-hosted runner。
## self-hosted runner build
1. 到專案頁面下，上排的Setting 
2. 在左邊欄位找到 Actions -> runners 就能看到 *add runner* 的選項。
![setting](https://github.com/markliou/Github_Action_Playground/blob/main/pics/setting.jpg?raw=true) 
3. 目前的runner可選擇性蠻多的，在Linux的部分，除了X86之外也能使用ARM，意思是有機會透過pi來進行佈建。進入*General*的選項以後，點下相對應的平台就會出現如何設定的指令。目前看來指令部分都蠻簡潔易懂。重點是**不能使用root權限進行runner設定，包括使用sudo也是不行的**。
4. runner跑起來後，就是需要修改原本的yml檔:
```
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```

## 使用self-hosted runner進行docker image build並進行推送
這功能需要自動登陸到dockerhub上。要針對dockerhub登陸做一些設定。原始參考文章[在這](https://medium.com/platformer-blog/lets-publish-a-docker-image-to-docker-hub-using-a-github-action-f0b17e5cceb3)。
### 設定登錄dockerhub的資訊
所有紀錄都存放在github的Secrets當中。尋找方式為:
```
Settings -> Serects -> New repository secret
```
Serects採用的是dictionary的想法，因此上面的Name可以打上自己習慣的就好。例如需要登到dockerhub需要帳密，所以只要創建兩變數: Docker_account、Docker_passwd。<p>
可以放心輸入即可，因為如果需要修改，再點進去做update的時候，原始資料並不會出現。表示如果忘記一開始輸入的數值就沒救了。不過也表示這十分安全。
### 遠端建構docker-in-docker (dind)
參考底下方式建構:<p>
https://github.com/jpetazzo/dind<p>
指令直接用:
```shell
sudo docker run -it -v /var/run/docker.sock:/var/run/docker.sock --privileged markliou/dind bash
```
接下來進入到container中，按照上面的*self-hosted*章節(或是github的[介紹網頁](https://github.com/markliou/Github_Action_Playground/settings/actions/runners/new?arch=x64&os=linux))，把container設定好。建議給label為"dind"，讓Action可以把建構container的任務丟到具有dind的container當中。
```shell
./config.sh --labels dind,self-hosted
```
github action的script不能使用root權限，所以要*修改run.sh*:
```shell
#user_id=`id -u`
#if [ $user_id -eq 0 -a -z "$RUNNER_ALLOW_RUNASROOT" ]; then
#    echo "Must not run interactively with sudo"
#    exit 1
#fi
```
全部註解掉以後就能使用root權限。因為在container裡面預設就是root，跑docker-in-docker也是使用root比較方便。