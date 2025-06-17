#!/usr/bin/env bash
# -------------------------------------------------
# custom analyzer(한국어 nori) 인덱스 생성 예시
# -------------------------------------------------
set -euo pipefail
ES=${ES_URL:-http://localhost:9200}

curl -s -XDELETE "$ES/movies_kr" -o /dev/null || true

curl -s -XPUT "$ES/movies_kr" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "analyzer": {
        "korean": {
          "type": "nori",
          "stopwords": "_korean_"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "korean"
      }
    }
  }
}' | jq

echo "✅ movies_kr 인덱스가 생성되었습니다."
