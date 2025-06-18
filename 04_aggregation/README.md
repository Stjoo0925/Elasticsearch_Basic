# 04_aggregation

`movies` 인덱스를 활용해 Aggregation 기본·응용 기능을 학습합니다.

## 파일 구성

| 경로                        | 설명                                              |
| --------------------------- | ------------------------------------------------- |
| `scripts/aggs_queries.http` | terms / avg / histogram / pipeline 집계 예제 쿼리 |

## 실습 순서

1. `02_basic_crud/scripts/setup.sh` 로 `movies` 데이터가 색인돼 있어야 합니다.
2. Kibana Dev Tools (`/app/dev_tools#/console`) 를 열고 `scripts/aggs_queries.http` 내용을 복사해 실행해 보세요.

## 추가 미션

- `rating` 필드를 기준으로 `range` aggregation 을 작성해 평점 구간별 영화 수 집계
- `movies` 인덱스에 필드를 추가해 날짜별 색인을 실습 후 `date_histogram` 으로 월별 변화를 시각화

## 실행 내용

```bash
### 1) 장르별 영화 수 + 평균 평점

{
  "took": 23,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "genre_stats": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "Sci-Fi",
          "doc_count": 2,
          "avg_rating": {
            "value": 8.700000286102295
          }
        },
        {
          "key": "Action",
          "doc_count": 1,
          "avg_rating": {
            "value": 9
          }
        },
        {
          "key": "Musical",
          "doc_count": 1,
          "avg_rating": {
            "value": 8
          }
        },
        {
          "key": "Thriller",
          "doc_count": 1,
          "avg_rating": {
            "value": 8.5
          }
        }
      ]
    }
  }
}

### 2) 연도 히스토그램(1년 간격)
{
  "took": 2,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "year_hist": {
      "buckets": [
        {
          "key": 2008,
          "doc_count": 1
        },
        {
          "key": 2009,
          "doc_count": 0
        },
        {
          "key": 2010,
          "doc_count": 1
        },
        {
          "key": 2011,
          "doc_count": 0
        },
        {
          "key": 2012,
          "doc_count": 0
        },
        {
          "key": 2013,
          "doc_count": 0
        },
        {
          "key": 2014,
          "doc_count": 1
        },
        {
          "key": 2015,
          "doc_count": 0
        },
        {
          "key": 2016,
          "doc_count": 1
        },
        {
          "key": 2017,
          "doc_count": 0
        },
        {
          "key": 2018,
          "doc_count": 0
        },
        {
          "key": 2019,
          "doc_count": 1
        }
      ]
    }
  }
}

### 3) 평점 상·하위 2개 장르만 출력(bucket_sort)
{
  "took": 6,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "genre_bucket": {
      "doc_count_error_upper_bound": 0,
      "sum_other_doc_count": 0,
      "buckets": [
        {
          "key": "Action",
          "doc_count": 1,
          "avg_rating": {
            "value": 9
          }
        },
        {
          "key": "Sci-Fi",
          "doc_count": 2,
          "avg_rating": {
            "value": 8.700000286102295
          }
        }
      ]
    }
  }
}

### 4) 전체 통계(stats)
{
  "took": 3,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "rating_stats": {
      "count": 5,
      "min": 8,
      "max": 9,
      "avg": 8.580000114440917,
      "sum": 42.90000057220459
    }
  }
}
```

## 추가 문제

```
### 5) 평점 구간별 영화 수 집계 (range aggregation)
POST /movies/_search
Content-Type: application/json

{
  "size": 0,                          // 검색 결과는 제외하고 집계만 반환
  "aggs": {
    "rating_ranges": {                 // 집계 이름 (사용자 정의)
      "range": {                       // range 집계 타입
        "field": "rating",             // 집계 대상 필드
        "ranges": [                    // 구간 정의 배열
          { "to": 8 },                 // 첫 번째 구간: rating < 8.0 (평점 낮음)
          { "from": 8, "to": 9 },      // 두 번째 구간: 8.0 ≤ rating < 9.0 (평점 보통)
          { "from": 9 }                // 세 번째 구간: rating ≥ 9.0 (평점 높음)
        ]
      }
    }
  }
}

{
  "took": 12,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 5,
      "relation": "eq"
    },
    "max_score": null,
    "hits": []
  },
  "aggregations": {
    "rating_ranges": {
      "buckets": [
        {
          "key": "*-8.0",
          "to": 8,
          "doc_count": 0
        },
        {
          "key": "8.0-9.0",
          "from": 8,
          "to": 9,
          "doc_count": 4
        },
        {
          "key": "9.0-*",
          "from": 9,
          "doc_count": 1
        }
      ]
    }
  }
}
```
