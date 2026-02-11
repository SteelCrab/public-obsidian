### Docker 설치 (Ubuntu)
```bash
# Docker GPG 키
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 리포지토리
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 사용자 그룹 추가
sudo usermod -aG docker $USER
newgrp docker
```

### AWS CLI 설치 (Ubuntu)
```bash
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```