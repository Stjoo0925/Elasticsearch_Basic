#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Elasticsearch + Kibana 컨테이너 기동 스크립트
# - docker compose up -d : 백그라운드 실행
# - 실행 후 접속 URL 출력
# ----------------------------------------------------------------------------
set -euo pipefail  # 오류 발생 시 즉시 종료, 정의되지 않은 변수 사용 금지

# 현재 스크립트 위치를 기준으로 compose 파일 상위 디렉터리로 이동
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$DIR/.."

# 컨테이너 실행 (백그라운드)
docker compose up -d

# 사용자가 바로 확인할 수 있도록 URL 안내
echo "✅ Elasticsearch: http://localhost:9200"
echo "✅ Kibana:        http://localhost:5601"
