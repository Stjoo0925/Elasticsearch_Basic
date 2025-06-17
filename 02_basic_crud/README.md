# 02_basic_crud

영화 데이터(`movies` 인덱스)를 이용해 CRUD 및 기본 검색을 실습합니다.

## 구성 파일

| 경로                          | 설명                                             |
| ----------------------------- | ------------------------------------------------ |
| `data/movies.ndjson`          | Bulk API용 NDJSON (.ndjson) 예제 데이터 5건      |
| `scripts/setup.sh`            | 인덱스 생성 + 데이터 적재 자동화 스크립트        |
| `scripts/sample_queries.http` | VS Code REST Client / Kibana Dev Tools 예제 쿼리 |

## 실습 순서

1. **환경 기동**: `../01_env_setup/scripts/start.sh` 실행 후 ES/Kibana 접속 확인
2. **데이터 적재**
   ```bash
   cd 02_basic_crud/scripts
   chmod +x setup.sh
   ./setup.sh
   ```
3. **CRUD 확인**
   1. `GET movies/_doc/1` → 단건 조회
   2. `DELETE movies/_doc/1` → 삭제 후 다시 색인 가능
4. **Query DSL 실습**
   - `sample_queries.http` 를 Kibana Dev Tools에 복사하여 실행
5. **응용**
   - `PUT movies/_mapping` 으로 `rating` 필드를 `scaled_float` 타입 0.1 스케일로 변경해보기
   - `POST movies/_search` 에 `sort` 추가해 평점순 정렬 테스트

> 참고: `setup.sh` 는 idempotent 하므로 재실행 시 기존 인덱스를 삭제하고 다시 색인을 수행합니다.

## 실행 방법

```bash
# 엘라스틱서치 환경 구동
./01_env_setup/scripts/start.sh

# 실습디렉토리 이동
cd 02_basic_crud/script

# 스크립트 권한 부여
chmod +x setup.sh

# 데이터 적재 실행
./setup.sh

# kibana dev tool 실행
http://localhost:5601/app/dev_tools#/console
```

## 실행내용

```
GET movies/_doc/1

{
  "_index": "movies",
  "_id": "1",
  "_version": 1,
  "_seq_no": 0,
  "_primary_term": 1,
  "found": true,
  "_source": {
    "title": "Inception",
    "year": 2010,
    "genre": "Sci-Fi",
    "rating": 8.8
  }
}
```

```
POST movies/_search
Content-Type: application/json

{
  "query": {
    "match": {
      "genre": "Sci-Fi"
    }
  }
}

{
  "took": 1,
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
    "max_score": 1,
    "hits": [
      {
        "_index": "movies",
        "_id": "1",
        "_score": 1,
        "_source": {
          "title": "Inception",
          "year": 2010,
          "genre": "Sci-Fi",
          "rating": 8.8
        }
      },
      {
        "_index": "movies",
        "_id": "2",
        "_score": 1,
        "_source": {
          "title": "Interstellar",
          "year": 2014,
          "genre": "Sci-Fi",
          "rating": 8.6
        }
      },
      {
        "_index": "movies",
        "_id": "3",
        "_score": 1,
        "_source": {
          "title": "The Dark Knight",
          "year": 2008,
          "genre": "Action",
          "rating": 9
        }
      },
      {
        "_index": "movies",
        "_id": "4",
        "_score": 1,
        "_source": {
          "title": "Parasite",
          "year": 2019,
          "genre": "Thriller",
          "rating": 8.5
        }
      },
      {
        "_index": "movies",
        "_id": "5",
        "_score": 1,
        "_source": {
          "title": "La La Land",
          "year": 2016,
          "genre": "Musical",
          "rating": 8
        }
      }
    ]
  }
}
```

```
POST movies/_search
Content-Type: application/json

{
  "query": {
    "bool": {
      "must": [
        { "match": { "genre": "Action" } }
      ],
      "filter": [
        { "range": { "rating": { "gte": 8.5 } } }
      ]
    }
  }
}

{
  "took": 1,
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
    "max_score": 1,
    "hits": [
      {
        "_index": "movies",
        "_id": "1",
        "_score": 1,
        "_source": {
          "title": "Inception",
          "year": 2010,
          "genre": "Sci-Fi",
          "rating": 8.8
        }
      },
      {
        "_index": "movies",
        "_id": "2",
        "_score": 1,
        "_source": {
          "title": "Interstellar",
          "year": 2014,
          "genre": "Sci-Fi",
          "rating": 8.6
        }
      },
      {
        "_index": "movies",
        "_id": "3",
        "_score": 1,
        "_source": {
          "title": "The Dark Knight",
          "year": 2008,
          "genre": "Action",
          "rating": 9
        }
      },
      {
        "_index": "movies",
        "_id": "4",
        "_score": 1,
        "_source": {
          "title": "Parasite",
          "year": 2019,
          "genre": "Thriller",
          "rating": 8.5
        }
      },
      {
        "_index": "movies",
        "_id": "5",
        "_score": 1,
        "_source": {
          "title": "La La Land",
          "year": 2016,
          "genre": "Musical",
          "rating": 8
        }
      }
    ]
  }
}
```
