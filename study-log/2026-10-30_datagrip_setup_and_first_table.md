# 2026-10-30 학습 로그: DataGrip 환경 세팅과 첫 테이블 만들기

> 김영한의 데이터베이스 강의(입문 + 기본)를 따라가며 로컬 MySQL에 첫 테이블을 만들고, DataGrip 사용 환경을 정리한 기록이다.

## 1. 오늘의 목표

- 로컬 MySQL(`local_mysql`)에 `my_shop` 데이터베이스와 `sample` 테이블 만들기
- 테이블 구조(`DESC`)와 데이터(`SELECT`)의 차이 이해하기
- DataGrip 편집 환경의 불편함(백스페이스, 대소문자, 쿼리 실행 범위) 해결하기

## 2. 실습 내용

### 2-1. 데이터베이스와 테이블 생성

```sql
CREATE DATABASE my_shop;
USE my_shop;

CREATE TABLE sample (
    product_id     INT PRIMARY KEY,
    name           VARCHAR(100),
    price          INT,
    stock_quantity INT,
    release_date   DATE
);
```

### 2-2. 구조 확인과 데이터 확인은 다른 명령이다

| 명령어 | 결과 표의 한 행이 의미하는 것 | 용도 |
|---|---|---|
| `DESC my_shop.sample;` | 컬럼 하나하나 | 설계도 확인 |
| `SELECT * FROM my_shop.sample;` | 데이터 한 건 한 건 | 내용 확인 |

- `DESC` 결과는 5 rows(컬럼 5개)였고, `SELECT` 결과는 **0 rows**  였다. 틀만 만들고 데이터는 아직 넣지 않았기 때문이다.
- SQL의 `VALUES (...)`는 파이썬의 튜플과 닮았다. 관계형 모델에서는 행을 실제로 튜플이라고 부른다.

### 2-3. 다음에 할 것: INSERT

```sql
INSERT INTO my_shop.sample (product_id, name, price, stock_quantity, release_date)
VALUES
    (1, '키보드', 35000, 120, '2026-01-15'),
    (2, '마우스', 25000, 200, '2026-02-01'),
    (3, '모니터', 280000, 45, '2026-03-10');
```

## 3. 오늘 만난 에러와 원인

| 증상 | 원인 | 해결 |
|---|---|---|
| `Table 'mysql.sample' doesn't exist` | 콘솔 오른쪽 위에서 선택된 스키마가 `my_shop`이 아니라 `mysql`이었다 | 스키마 선택 칸을 `my_shop`으로 바꾸거나 `my_shop.sample`처럼 이름을 붙인다 |
| 백스페이스를 눌러도 아무 변화가 없음 | 키맵 `macOS copy`에서 Backspace 키 연결이 빠져 있었다 | Keymap → Editor Actions → Backspace에 단축키를 다시 추가한다 |
| `⌘ + Enter` 때 실행 후보 팝업이 뜸 | 쿼리 사이에 빈 줄이 없어 여러 문장이 한 덩어리로 인식됨 | 쿼리 사이에 빈 줄을 넣거나, 실행할 부분만 선택한다 |

> 교훈: "테이블이 분명 있는데 없다고 나온다"면 **어느 데이터베이스를 보고 있는지**  부터 확인한다.

## 4. DataGrip 설정 메모

- 대소문자 자동 정리: `Settings → Editor → Code Style → SQL → General → Case`에서 Keywords, Built-in types, Built-in functions는 `To upper`, Identifiers는 `Do not change`로 둔다. 코드 정리는 `⌘ + ⌥ + L`이다.
- `Treat asterisk as a regular element`는 공백이 아니라 줄바꿈 규칙이므로 켜지 않는다.
- Database Explorer 창은 `⌘ + 1`로 다시 열 수 있다.
- 트랜잭션 모드가 `Tx: Auto`이면 `UPDATE`, `DELETE`, `DROP`이 즉시 확정된다. 파괴적인 명령은 콘솔에 남겨 두지 않는다.

## 5. 유용한 단축키

| 동작 | 단축키 |
|---|---|
| 현재 줄 삭제 | `⌘ + Delete` |
| 앞 단어 삭제 | `⌥ + Delete` |
| 선택 영역 확장 | `⌥ + ↑` |
| 쿼리 실행 | `⌘ + Enter` |
| 코드 정리 | `⌘ + ⌥ + L` |

## 6. 내일(11/1 데이터리안 캠프 시작 전)의 작은 목표

1. `INSERT`로 3건을 넣고 `SELECT`가 **0 rows에서 3 rows**  로 바뀌는 것을 확인한다.
2. 같은 `product_id`를 한 번 더 넣어 기본키 중복 에러를 직접 확인한다.
3. 같은 데이터를 파이썬 튜플 리스트로 만들어 `pd.DataFrame`으로 비교한다.
