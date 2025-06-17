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
```
