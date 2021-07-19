FROM ubuntu

RUN apt update -y && apt install openssh-server net-tools python ansible sudo -y

# installing docker 
RUN apt update -y ; apt upgrade -y;\
    apt-get install -y\
    sudo \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release 
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg ;\
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
RUN apt-get update -y;\
    apt-get install -y docker-ce docker-ce-cli containerd.io
