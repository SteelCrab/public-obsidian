## Docker 설치 
```shell
# Docker 설치
sudo yum update -y
sudo yum install -y docker git python3
sudo systemctl start docker
sudo systemctl enable docker

# 사용자 그룹 추가
sudo usermod -aG docker $USER
newgrp docker
```

## AWS ECR login (Amazone Linux)

```
aws configure
```

