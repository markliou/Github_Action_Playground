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