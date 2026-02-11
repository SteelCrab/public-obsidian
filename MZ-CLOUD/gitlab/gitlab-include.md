# GitLab Include

#gitlab #cicd #include

---

외부 YAML 파일을 포함하여 설정 재사용.

## include 유형

| 유형 | 설명 |
|------|------|
| `local` | 같은 저장소 |
| `project` | 다른 프로젝트 |
| `remote` | URL |
| `template` | GitLab 템플릿 |

## local

```yaml
include:
  - local: '/ci/build.yml'
  - local: '/ci/test.yml'
```

## project

```yaml
include:
  - project: 'my-group/ci-templates'
    file: '/templates/build.yml'
    ref: main
```

## remote

```yaml
include:
  - remote: 'https://example.com/ci/template.yml'
```

## template

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml
  - template: Security/SAST.gitlab-ci.yml
```

## 여러 파일

```yaml
include:
  - local: '/ci/variables.yml'
  - project: 'group/templates'
    file: '/build.yml'
  - template: Security/SAST.gitlab-ci.yml
```

## 재정의

include된 설정은 로컬에서 재정의 가능.

```yaml
include:
  - local: '/ci/base.yml'

build:
  script: npm run build  # base.yml의 build 재정의
```
