#!/usr/bin/env bash
# ---------------------------------------------------------------
# 영화 샘플 인덱스 생성 + 데이터 적재 스크립트
# ---------------------------------------------------------------
set -euo pipefail  # 오류 발생 시 즉시 종료

ES=${ES_URL:-http://localhost:9200}  # ES REST 엔드포인트
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DATA_FILE="$SCRIPT_DIR/../data/movies.ndjson"

# 기존 인덱스 제거(있으면)
curl -s -XDELETE "$ES/movies" -o /dev/null || true

# 새 인덱스 생성(동적 매핑)
curl -s -XPUT "$ES/movies" -H 'Content-Type: application/json' -d'{}' | jq

# Bulk API 로 데이터 적재 (refresh=true 로 즉시 색인 가시화)
curl -s -XPOST "$ES/_bulk?refresh=true" \
     -H 'Content-Type: application/x-ndjson' \
     --data-binary "@$DATA_FILE" | jq

# 색인 건수 출력
curl -s "$ES/movies/_count" | jq '.count as $c | "📦 총 "+($c|tostring)+" 건 색인 완료"'
