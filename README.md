# AWS Infrastructure Provisioning Project for Beforegoing (Terraform)

## 1. 프로젝트 개요

이 프로젝트는 **Terraform**을 사용하여 AWS 클라우드 인프라를 코드로 관리(IaC, Infrastructure as Code)하기 위한 저장소입니다.

`beforegoing`이라는 서비스의 인프라를 **개발(dev), 스테이징(stg), 프로덕션(prod)** 환경으로 나누어 관리하며, **다중 리전(ap-northeast-1, ap-northeast-2)** 배포를 지원하는 구조를 가지고 있습니다. 또한, Go로 작성된 자동화 스크립트를 통해 인프라 배포를 간소화합니다.

## 2. 주요 특징 및 기술 스택

- **Terraform 기반의 IaC**: 모든 인프라 자원을 코드로 정의하여 일관성 있고 재현 가능한 환경 구축을 보장합니다.
- **모듈식 아키텍처**: 공통적으로 사용되는 리소스 그룹을 `_module` 디렉터리에서 모듈로 정의하여 코드 재사용성을 높이고 유지보수를 용이하게 합니다.
- **다중 환경 및 리전 관리**: `beforegoingd`(dev), `beforegoings`(staging), `beforegoingp`(prod)와 같이 환경별로 디렉터리를 분리하고, 리전(ap-northeast-1, ap-northeast-2)에 따라 구체적인 리소스를 배포합니다.
- **Go를 이용한 배포 자동화**: `terraform-auto` 디렉터리 내의 Go 애플리케이션을 통해 복잡한 Terraform 명령어를 추상화하고, 설정 파일(`config-*.yaml`) 기반으로 특정 환경의 배포를 자동화합니다.
- **기술 스택**:
  - **IaC**: Terraform
  - **Cloud**: AWS
  - **Automation**: Go

## 3. 디렉터리 구조

프로젝트는 크게 `terraform`과 `terraform-auto` 두 부분으로 구성됩니다.

```
/
├── terraform/
│   ├── <서비스명>/                    # e.g., vpc, ecs, rds, s3
│   │   ├── _module/                 # 해당 서비스의 재사용 가능한 Terraform 모듈
│   │   └── teamund/                 # 모듈을 사용하여 실제 환경에 배포하는 코드
│   │       └── <환경명>_<리전>/        # e.g., beforegoingd_apnortheast1
│   └── variables/                   # 여러 환경에서 공통으로 사용하는 변수
│
└── terraform-auto/
    ├── beforegoingd/                # 개발 환경 자동화 스크립트
    └── beforegoingsp/               # 스테이징/프로덕션 환경 자동화 스크립트
```

- **`terraform/<서비스명>/_module/`**: VPC, ECR, ECS Cluster 등과 같은 AWS 리소스를 생성하기 위한 범용 모듈이 위치합니다.
- **`terraform/<서비스명>/teamund/<환경명>_<리전>/`**: 위 모듈을 가져와(`source`) 특정 환경과 리전에 필요한 변수(e.g., `terraform.tfvars`)를 주입하여 실제 인프라를 정의하는 곳입니다.
- **`terraform-auto/`**: `config-dev.yaml`, `config-stg.yaml` 등의 설정 파일을 읽어 해당 환경에 맞는 Terraform 작업을 수행하는 Go 스크립트가 위치합니다. 이를 통해 수동 명령어 실행 시 발생할 수 있는 실수를 줄입니다.

## 4. 관리하는 AWS 리소스

본 프로젝트를 통해 프로비저닝되는 주요 AWS 리소스는 다음과 같습니다.

- **Networking**: VPC, Route 53, CloudFront, Application Load Balancer
- **Compute**: ECS, Lambda
- **Storage**: S3, ECR
- **Database**: RDS(MySQL), ElastiCache(Redis)
- **Security & Identity**: IAM, WAF
- **API Management**: API Gateway
- **Management & Governance**: Resource Explorer

## 5. 사용 방법 (예시)

특정 환경의 인프라를 배포, 수정 또는 삭제하기 위해서는 해당 환경의 디렉터리로 이동하여 Terraform 명령어를 실행합니다.

예를 들어, **개발 환경(dev)의 `ap-northeast-1` 리전 VPC**를 배포하는 경우:

```bash
# 1. 해당 환경의 디렉터리로 이동
cd /workspace/aws-provisioning/terraform/vpc/beforegoingd_apnortheast1

# 2. Terraform 초기화
terraform init

# 3. 변경 사항 계획 확인
terraform plan

# 4. 인프라 배포 (또는 수정)
terraform apply
```

## 6. 배포 자동화 (terraform-auto)

`terraform-auto` 디렉터리의 Go 스크립트는 위와 같은 수동 배포 과정을 자동화합니다. 예를 들어, `beforegoingsp` 디렉터리의 `main.go`는 `config-stg.yaml` 파일을 읽어 스테이징 환경에 필요한 모든 Terraform 작업을 순차적으로 실행할 수 있습니다.
