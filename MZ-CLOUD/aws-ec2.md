

| 플레이스홀더            | 설명                                       | 예시                        |
| :---------------- | :--------------------------------------- | :------------------------ |
| `<PREFIX>`        | 리소스 접두사                                  | pista, team1              |
| `<TEAM>`          | 팀 이름                                     | team1                     |
| `<USERNAME>`      | 사용자 이름                                   | pyh5523                   |
| `<ENV>`           | 환경                                       | test, dev, prod           |
| `<AMI>`           | AMI 이름/ID                                | Ubuntu, Amazon Linux 2023 |
| `<INSTANCE_TYPE>` | 인스턴스 유형                                  | t2.micro, t3.small        |
| `<KEY_PAIR>`      | 키 페어 이름                                  | pistakey                  |
| `<VPC>`           | VPC 이름                                   | pista-vpc                 |
| `<SUBNET>`        | 서브넷 이름                                   | pista-subnet-public1-1a   |
| `<PUBLIC_IP>`     | 퍼블릭 IP 할당                                | ✅, ❌                      |
| `<SG>`            | [보안 그룹](../../network/security-group.md) | pista-sg-web              |
| `<STORAGE>`       | 스토리지 구성                                  | 8 GiB gp3                 |
| `<USER_DATA>`     | 사용자 데이터 스크립트                             | web.sh, api.sh            |


---

## 템플릿

### 인스턴스 생성 (`<PREFIX>`-ec2-`<ROLE>`)

| 항목                | 값                                         |
| :---------------- | :---------------------------------------- |
| 태그-Name           | `<PREFIX>`-ec2-`<ROLE>`                   |
| 태그-Team           | `<TEAM>`                                  |
| 태그-Username       | `<USERNAME>`                              |
| 태그-Environment    | `<ENV>`                                   |
| AMI               | `<AMI>`                                   |
| 인스턴스 유형           | `<INSTANCE_TYPE>`                         |
| 키 페어              | `<KEY_PAIR>`                              |
| 네트워크-VPC          | `<VPC>`                                   |
| 네트워크-서브넷          | `<SUBNET>`                                |
| 네트워크-퍼블릭 IP 자동 할당 | `<PUBLIC_IP>`                             |
| 네트워크-보안 그룹        | [`<SG>`](../../network/security-group.md) |
| 스토리지 구성           | `<STORAGE>`                               |
| 고급-사용자 데이터        | [scripts/`<USER_DATA>`](scripts/)         |

---

## 프리셋

### Web Server (Public)

| 플레이스홀더 | 값 |
|:---|:---|
| `<PREFIX>` | pista |
| `<ROLE>` | nginx |
| `<TEAM>` | team1 |
| `<USERNAME>` | pyh5523 |
| `<ENV>` | test |
| `<AMI>` | Ubuntu |
| `<INSTANCE_TYPE>` | t2.micro |
| `<KEY_PAIR>` | pistakey |
| `<VPC>` | pista-vpc |
| `<SUBNET>` | pista-subnet-public1-1a |
| `<PUBLIC_IP>` | ✅ |
| `<SG>` | pista-sg-web |
| `<STORAGE>` | 8 GiB gp3 |
| `<USER_DATA>` | web.sh |

### API Server (Private)

| 플레이스홀더 | 값 |
|:---|:---|
| `<PREFIX>` | pista |
| `<ROLE>` | api |
| `<AMI>` | Ubuntu |
| `<INSTANCE_TYPE>` | t3.small |
| `<SUBNET>` | pista-subnet-private1-1a |
| `<PUBLIC_IP>` | ❌ |
| `<SG>` | pista-sg-api |
| `<STORAGE>` | 20 GiB gp3 |
| `<USER_DATA>` | api.sh |

### ECS Container Instance

| 플레이스홀더 | 값 |
|:---|:---|
| `<PREFIX>` | pista |
| `<ROLE>` | ecs |
| `<AMI>` | ECS-Optimized Amazon Linux 2023 |
| `<INSTANCE_TYPE>` | t3.medium |
| `<SUBNET>` | pista-subnet-private1-1a |
| `<PUBLIC_IP>` | ❌ |
| `<SG>` | pista-sg-ecs |
| `<STORAGE>` | 30 GiB gp3 |
| `<USER_DATA>` | ecs-userdata.sh |
