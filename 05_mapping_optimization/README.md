# 05_mapping_optimization

인덱스 매핑 최적화 기법을 학습하여 저장공간과 성능을 개선합니다.

## 파일 구성

| 경로                             | 설명                                   |
| -------------------------------- | -------------------------------------- |
| `scripts/mapping_examples.http`  | 필드 타입 최적화 및 \_reindex API 예제 |
| `scripts/dynamic_templates.http` | 동적 템플릿으로 자동 매핑 규칙 설정    |

## 실습 순서

1. **현재 매핑 분석**: `GET /movies/_mapping` 으로 동적 생성된 매핑 확인
2. **최적화된 인덱스 생성**: `scaled_float`, `short`, `keyword` 등으로 타입 개선
3. **데이터 마이그레이션**: `_reindex` API로 기존 데이터를 새 인덱스로 복사
4. **동적 템플릿 실습**: 규칙 기반 자동 매핑으로 일관성 유지

## 학습 포인트

- **메모리 효율**: `scaled_float` vs `float`, `short` vs `integer`
- **검색 vs 집계**: `text` + `keyword` 멀티필드 활용
- **동적 템플릿**: 새 필드가 추가될 때 자동으로 적절한 타입 할당

## 추가 미션

- `date` 타입 필드를 추가해 출시일 정보 색인
- `nested` 타입으로 배우 리스트 구조 설계

## 최적화

```
# 기존 movies 인덱스의 매핑 구조 확인
GET /movies/_mapping

{
  "movies": {
    "mappings": {
      "properties": {
        "genre": {
          "type": "text",                    # 동적 매핑으로 text + keyword 멀티필드 생성
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256            # 256자 초과 시 색인 제외
            }
          }
        },
        "rating": {
          "type": "float"                    # 기본 float (4바이트) - 메모리 비효율적
        },
        "title": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "year": {
          "type": "long"                     # 기본 long (8바이트) - 연도에는 과도함
        }
      }
    }
  }
}

# 최적화된 새 인덱스 생성 (메모리 효율성 개선)
PUT /movies_optimized
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",                    # 전문 검색용 (형태소 분석)
        "fields": {
          "keyword": {                     # 정렬/집계용 서브필드 (원본 그대로)
            "type": "keyword"
          }
        }
      },
      "year": { "type": "short" },         # 연도는 short(2바이트)로 충분 (-32,768 ~ 32,767)
      "genre": { "type": "keyword" },      # 카테고리는 keyword만 (검색보다 집계 중심)
      "rating": {
        "type": "scaled_float",            # 메모리 효율적인 실수형
        "scaling_factor": 10               # 소수점 1자리까지 저장 (8.8 → 88로 내부 저장)
      }
    }
  }
}

{
  "acknowledged": true,                    # 인덱스 생성 성공
  "shards_acknowledged": true,             # 샤드 할당 성공
  "index": "movies_optimized"
}

# 기존 데이터를 새 인덱스로 마이그레이션
POST /_reindex
{
  "source": { "index": "movies" },        # 원본 인덱스
  "dest": { "index": "movies_optimized" } # 대상 인덱스 (매핑에 맞게 자동 변환)
}

{
  "took": 11,                              # 처리 시간 (밀리초)
  "timed_out": false,                      # 타임아웃 없음
  "total": 5,                              # 총 처리 문서 수
  "updated": 0,                            # 업데이트된 문서 수
  "created": 5,                            # 새로 생성된 문서 수
  "deleted": 0,                            # 삭제된 문서 수
  "batches": 1,                            # 배치 수
  "version_conflicts": 0,                  # 버전 충돌 없음
  "noops": 0,                              # 변경사항 없는 문서 수
  "retries": {
    "bulk": 0,                             # 벌크 재시도 횟수
    "search": 0                            # 검색 재시도 횟수
  },
  "throttled_millis": 0,                   # 스로틀링 시간
  "requests_per_second": -1,               # 초당 요청 수 (무제한)
  "throttled_until_millis": 0,             # 스로틀링 해제 시간
  "failures": []                           # 실패 목록 (비어있음 = 성공)
}

# 최적화된 인덱스에서 집계 테스트
POST /movies_optimized/_search
{
  "size": 0,                               # 검색 결과 제외, 집계만 반환
  "aggs": {
    "avg_rating": { "avg": { "field": "rating" } },      # 평균 평점 계산
    "genre_terms": { "terms": { "field": "genre" } }     # 장르별 문서 수 집계
  }
}

{
  "took": 14,                              # 쿼리 실행 시간
  "timed_out": false,
  "_shards": {
    "total": 1,                            # 검색 대상 샤드 수
    "successful": 1,                       # 성공한 샤드 수
    "skipped": 0,                          # 건너뛴 샤드 수
    "failed": 0                            # 실패한 샤드 수
  },
  "hits": {
    "total": {
      "value": 5,                          # 총 문서 수
      "relation": "eq"                     # 정확한 수치
    },
    "max_score": null,                     # 점수 계산 안 함 (집계만)
    "hits": []                             # 검색 결과 비어있음 (size: 0)
  },
  "aggregations": {
    "genre_terms": {                       # 장르별 집계 결과
      "doc_count_error_upper_bound": 0,    # 오차 상한선
      "sum_other_doc_count": 0,            # 기타 문서 수
      "buckets": [                         # 버킷별 결과
        {
          "key": "Sci-Fi",                 # 장르명
          "doc_count": 2                   # 해당 장르 영화 수
        },
        {
          "key": "Action",
          "doc_count": 1
        },
        {
          "key": "Musical",
          "doc_count": 1
        },
        {
          "key": "Thriller",
          "doc_count": 1
        }
      ]
    },
    "avg_rating": {
      "value": 8.58                        # 전체 평균 평점
    }
  }
}
```

## 동적 템플릿

```
# 동적 템플릿이 적용된 인덱스 생성
PUT /movies_with_templates
{
  "settings": {
    "number_of_shards": 1,                 # 샤드 1개 (단일 노드)
    "number_of_replicas": 0                # 복제본 없음 (성능 우선)
  },
  "mappings": {
    "dynamic_templates": [                 # 동적 매핑 규칙 정의
      {
        "strings_as_keywords": {           # 규칙 1: 문자열 처리
          "match_mapping_type": "string",  # 문자열 타입 감지 시
          "mapping": { "type": "keyword" } # keyword 타입으로 자동 매핑
        }
      },
      {
        "integers_as_short": {             # 규칙 2: 정수 처리
          "match_mapping_type": "long",    # long 타입 감지 시
          "mapping": { "type": "short" }   # short 타입으로 변경 (메모리 절약)
        }
      }
    ]
  }
}
```
