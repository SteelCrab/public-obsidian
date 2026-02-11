# GitLab Runner DNS 설정

> `docker build` 시 DNS 해석 실패 해결

## 설정

```bash
# GitLab VM (172.100.100.8)
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["172.100.100.8:5050"],
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

sudo systemctl restart docker
```
