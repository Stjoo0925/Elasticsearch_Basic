# 03_query_dsl

`movies` 인덱스 데이터를 활용해 Query DSL 의 핵심 구문을 실습하고, Analyzer 차이를 체험합니다.

## 파일 구성

| 경로                             | 설명                                                |
| -------------------------------- | --------------------------------------------------- |
| `scripts/sample_queries.http`    | match / term / bool / highlight / analyzer API 예제 |
| `scripts/create_custom_index.sh` | nori(한국어) 분석기를 가진 index 생성 스크립트      |

## 실습 순서

1. **03 폴더 이동**
   ```bash
   cd 03_query_dsl/scripts
   ```
2. **Analyzer 체험**
   ```bash
   chmod +x create_custom_index.sh
   ./create_custom_index.sh
   # Kibana Dev Tools 에서 _analyze API 비교 실행
   ```
3. **Query DSL 실행**
   - `sample_queries.http` 파일 내용을 Kibana Dev Tools 로드 후 ⌘+Enter 로 실행
   - match vs term, bool 필터, 하이라이트 결과를 관찰

## 추가 미션

- `movies` 인덱스에 `match_phrase` 쿼리를 작성해 "Dark Knight" 정확 구문 검색 해보기
- `movies_kr` 인덱스에 한국어 제목 데이터를 입력하고 검색 정확도를 비교

## 실행 방법

```bash
# 엘라스틱서치 환경 구동
./01_env_setup/scripts/start.sh

# 실습디렉토리 이동
cd 03_query_dsl/scripts

# 스크립트 권한 부여
chmod +x setup.sh

# 데이터 적재 실행
./create_custom_index.sh

# kibana dev tool 실행
http://localhost:5601/app/dev_tools#/console
```

## 실행내용

```
POST movies/_search
Content-Type: application/json

{
  "query": {
    "match": {
      "title": "inception"
    }
  }
}

"hits": {
  "total": {
    "value": 1,
    "relation": "eq"
  },
  "max_score": 1.6943598,
  "hits": [
    {
      "_index": "movies",
      "_id": "1",
      "_score": 1.6943598,
      "_source": {
        "title": "Inception",
        "year": 2010,
        "genre": "Sci-Fi",
        "rating": 8.8
      }
    }
  ]
}

POST http://localhost:9200/_analyze
Content-Type: application/json

{
  "analyzer": "standard",
  "text": "Elasticsearch Basic Study"
}

{
  "tokens": [
    {
      "token": "elasticsearch",
      "start_offset": 0,
      "end_offset": 13,
      "type": "<ALPHANUM>",
      "position": 0
    },
    {
      "token": "basic",
      "start_offset": 14,
      "end_offset": 19,
      "type": "<ALPHANUM>",
      "position": 1
    },
    {
      "token": "study",
      "start_offset": 20,
      "end_offset": 25,
      "type": "<ALPHANUM>",
      "position": 2
    }
  ]
}
```
