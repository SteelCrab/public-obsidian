# AWS Auto Scaling Group

#aws #asg #autoscaling #ec2 #scaling

---

EC2 인스턴스를 자동으로 확장/축소하는 그룹.

## ASG 목록

```bash
aws autoscaling describe-auto-scaling-groups
```

## 특정 ASG 조회

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names my-asg
```

## ASG 생성

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version='$Latest' \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-12345,subnet-67890" \
  --target-group-arns arn:aws:elasticloadbalancing:... \
  --health-check-type ELB \
  --health-check-grace-period 300
```

## 용량 변경

```bash
# Desired Capacity 변경
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name my-asg \
  --desired-capacity 3

# Min/Max 변경
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --min-size 2 \
  --max-size 10
```

## 인스턴스 목록

```bash
aws autoscaling describe-auto-scaling-instances \
  --output table
```

## 스케일링 정책

```bash
# Target Tracking 정책 생성
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name cpu-target-tracking \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 70.0
  }'
```

## ASG 일시 중지/재개

```bash
# 스케일링 일시 중지
aws autoscaling suspend-processes \
  --auto-scaling-group-name my-asg \
  --scaling-processes Launch Terminate

# 스케일링 재개
aws autoscaling resume-processes \
  --auto-scaling-group-name my-asg \
  --scaling-processes Launch Terminate
```

## 인스턴스 보호

```bash
# 인스턴스 보호 활성화
aws autoscaling set-instance-protection \
  --instance-ids i-1234567890abcdef0 \
  --auto-scaling-group-name my-asg \
  --protected-from-scale-in

# 보호 해제
aws autoscaling set-instance-protection \
  --instance-ids i-1234567890abcdef0 \
  --auto-scaling-group-name my-asg \
  --no-protected-from-scale-in
```

## Launch Template 업데이트

```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version='$Latest'
```

## 인스턴스 새로고침

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name my-asg \
  --preferences '{"MinHealthyPercentage": 90}'
```

## ASG 삭제

```bash
# 인스턴스와 함께 삭제
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --force-delete
```

## 주요 옵션

| 옵션 | 설명 |
|------|------|
| `--min-size` | 최소 인스턴스 수 |
| `--max-size` | 최대 인스턴스 수 |
| `--desired-capacity` | 희망 인스턴스 수 |
| `--health-check-type` | EC2 또는 ELB |
| `--health-check-grace-period` | 헬스체크 유예 시간 (초) |
| `--target-group-arns` | ALB/NLB 타겟 그룹 ARN |
| `--vpc-zone-identifier` | 서브넷 ID 목록 (쉼표 구분) |

## 관련 노트

- [[aws-ec2]] - EC2 인스턴스
- [[aws-elb]] - 로드밸런서
- [[aws-cloudwatch]] - CloudWatch 모니터링
