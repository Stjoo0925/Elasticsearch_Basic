# 01_env_setup

30초 만에 Elasticsearch + Kibana 환경을 띄우기 위한 Docker Compose 구성입니다.

## 사용법
```bash
# 컨테이너 기동
./scripts/start.sh

# 상태 확인
curl -s localhost:9200 | jq '.cluster_name, .version.number'

# Kibana 접속
open http://localhost:5601

# 컨테이너 중지 및 정리
./scripts/stop.sh
```

## 구성 파일
- `docker-compose.yml` : 단일 노드 ES(8.x) & Kibana 서비스 정의
- `scripts/start.sh` : 백그라운드 실행 스크립트
- `scripts/stop.sh`  : 컨테이너 중지/볼륨 삭제

## 요구 사항
- Docker ≥ 20.10
- docker-compose(또는 compose v2 플러그인)

## 참고
보안 기능을 비활성화(single-node)로 간소화했습니다. 운영 환경에서는 TLS/계정 설정이 필요합니다.
