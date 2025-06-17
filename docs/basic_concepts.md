# Elasticsearch 기본 개념

## Index

- 데이터가 저장되는 논리적 단위. RDBMS의 database/table 유사.
- 하나의 Index는 여러 Shard로 물리 분할 가능.

## Document

- JSON 형식의 단일 레코드.
- Index 내부에서 `_id` 로 구분.

## Cluster & Node

- Cluster: 하나 이상의 Node 집합, 동일한 Cluster 이름 공유.
- Node: Elasticsearch 프로세스 단일 인스턴스, Master / Data / Coordinating 역할.

## Shard & Replica

- Shard: Index를 물리적으로 나눈 단위, 데이터 분산 및 병렬 처리.
- Replica: Shard 사본, 고가용성 및 읽기 성능 향상.

## Mapping & Field Type

- 스키마 정의. 각 필드 타입과 Analyzer 지정.

## Analyzer & Tokenizer

- Analyzer: 텍스트를 토큰 리스트로 변환 후 필터 적용.
- Tokenizer: 문장을 토큰으로 자르는 역할.

## Query DSL

- JSON 기반 도메인 언어로 검색/집계 요청 정의.

## Aggregation

- 대용량 데이터에 대한 통계, 그룹화 계산.

## Ingest Pipeline

- 색인 전에 문서를 전처리하는 Processor 체인.
