# Problem 2: 카테고리별 판매 현황 분석

## 📌 문제 정의

**요구사항:**
- 각 **카테고리**  별로 다음을 계산하기
  - 총 판매액 (모든 주문의 수량 × 가격 합계)
  - 판매 건수 (주문 건수)
  - 평균 판매액 (주문당 평균 금액)

**데이터베이스:** my_shop2

**주어진 데이터:**
- orders 테이블: order_id, product_id, quantity
- products 테이블: product_id, category, price
- users 테이블: user_id, name

---

## 🔍 1단계: 문제 분석

이 문제를 풀기 위해 필요한 정보를 정리해봅시다.

**우리가 찾고 있는 것:**
1. **카테고리 이름** - products.category
2. **총 판매액** - SUM(quantity × price)
3. **판매 건수** - COUNT(order_id)
4. **평균 판매액** - AVG(quantity × price)

**핵심 질문:**
- 어느 테이블에서 카테고리 정보를 가져올 것인가?
  → products 테이블
- 어디서 주문 수량 정보를 가져올 것인가?
  → orders 테이블
- 어디서 상품 가격 정보를 가져올 것인가?
  → products 테이블

---

## 🔍 2단계: 테이블 구조 확인

### orders 테이블
```
order_id | product_id | quantity | user_id
---------|-----------|----------|--------
1        | 10        | 2        | 1
2        | 11        | 1        | 2
3        | 10        | 3        | 1
```

### products 테이블
```
product_id | category | price
-----------|----------|------
10         | 전자제품 | 50000
11         | 의류     | 30000
12         | 전자제품 | 80000
```

### 테이블 연결 방식
- orders.product_id → products.product_id (INNER JOIN)
- products 테이블에서 category와 price를 함께 가져옴

---

## 💡 3단계: 논리 구성 (JOIN 전략)

**어느 테이블을 기준으로 시작할 것인가?**

`FROM orders o`로 시작합니다. 왜냐하면:
- 판매 건수를 세기 위해서는 orders 행의 개수가 필요
- orders가 "사실의 원천 (source of truth)"

**어떤 테이블을 JOIN할 것인가?**

`INNER JOIN products p ON o.product_id = p.product_id`

이유:
- products 테이블은 category와 price 정보 제공
- product_id를 통해 연결
- INNER JOIN이므로 존재하지 않는 상품은 제외

**JOIN 후 구조:**
```
orders (o) 
  ↓ INNER JOIN
products (p) on o.product_id = p.product_id
  ↓
결과: 각 주문마다 해당 상품의 카테고리와 가격 정보 추가
```

---

## 💡 4단계: 집계 전략 (GROUP BY와 집계 함수)

**GROUP BY 선택:**

`GROUP BY p.category`

이유:
- 우리는 **카테고리별**  로 묶어서 보고 싶음
- 같은 카테고리의 모든 주문을 하나의 그룹으로 만듦

**집계 함수 선정:**

1. **총 판매액:** `SUM(o.quantity * p.price)`
   - 각 주문의 판매액(수량 × 가격)을 모두 더함
   - 카테고리별로 집계됨

2. **판매 건수:** `COUNT(*)`
   - 각 카테고리의 주문 건수를 셈
   - 또는 `COUNT(o.order_id)` 사용 가능

3. **평균 판매액:** `AVG(o.quantity * p.price)`
   - 각 카테고리의 평균 주문 금액
   - (총 판매액 ÷ 판매 건수)와 동일한 결과

---

## ✅ 5단계: 최종 쿼리 작성

```sql
SELECT
    p.category AS category_name,
    SUM(o.quantity * p.price) AS total_sales,
    COUNT(*) AS order_count,
    AVG(o.quantity * p.price) AS avg_sales_per_order
FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;
```

**쿼리 해석:**

| 부분 | 역할 |
|------|------|
| `SELECT p.category` | 카테고리 이름 선택 |
| `SUM(o.quantity * p.price)` | 카테고리별 총 판매액 계산 |
| `COUNT(*)` | 카테고리별 주문 건수 계산 |
| `AVG(o.quantity * p.price)` | 카테고리별 평균 판매액 계산 |
| `FROM orders o` | 기준 테이블: orders |
| `INNER JOIN products p` | products 테이블과 연결 |
| `GROUP BY p.category` | 카테고리별로 그룹화 |
| `ORDER BY total_sales DESC` | 총 판매액이 높은 순서부터 정렬 |

---

## 📊 예상 결과

```
category_name | total_sales | order_count | avg_sales_per_order
--------------|-------------|-------------|---------------------
전자제품      | 330000      | 3           | 110000
의류          | 90000       | 2           | 45000
도서          | 35000       | 1           | 35000
```

**해석:**
- 전자제품이 가장 높은 매출을 기록
- 평균 주문 금액도 전자제품이 가장 높음
- 총 3개 카테고리가 판매됨

---

## 🎓 핵심 개념 정리

### 다중 집계 함수 (Multiple Aggregate Functions)

한 번의 GROUP BY로 여러 집계 함수를 동시에 사용할 수 있습니다:

```sql
GROUP BY category
  ├─ SUM() : 합계
  ├─ COUNT() : 개수
  ├─ AVG() : 평균
  ├─ MAX() : 최댓값
  └─ MIN() : 최솟값
```

### 계산식을 포함한 집계

`SUM(o.quantity * p.price)` 처럼 두 컬럼의 곱셈을 먼저 계산한 후 집계하는 방식:

1. 각 행마다 quantity × price 계산
2. 결과를 SUM으로 모두 더함
3. GROUP BY에 의해 카테고리별로 분리

### SQL 실행 순서

```
1. FROM orders o
   ↓ orders 테이블 읽음
2. INNER JOIN products p
   ↓ product_id 기준으로 products와 연결
3. GROUP BY p.category
   ↓ 카테고리별로 행들을 그룹화
4. SELECT + 집계함수
   ↓ 각 그룹에 대해 집계 계산
5. ORDER BY total_sales DESC
   ↓ 결과를 판매액 내림차순으로 정렬
```

---

## 💡 배운 점

1. **JOIN 후 GROUP BY 순서**
   - 먼저 필요한 테이블들을 JOIN으로 연결
   - 그 다음 원하는 기준으로 GROUP BY 실행

2. **여러 집계함수의 조합**
   - 하나의 쿼리에서 SUM, COUNT, AVG를 동시에 사용
   - 각각 다른 목적으로 활용 (총액, 개수, 평균)

3. **계산을 포함한 집계**
   - `SUM(quantity * price)` 같이 계산 과정을 집계함수 안에 포함
   - 단순한 컬럼 집계보다 실무적인 인사이트 제공

4. **ORDER BY로 우선순위 표현**
   - DESC를 사용해 가장 중요한 카테고리(높은 매출)부터 표시
   - 비즈니스 의사결정에 도움

---

## ✅ 데이터 검증

```sql
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS total_orders
FROM orders;
```

| total_rows | total_orders |
|:---:|:---:|
| 7 | 7 |

확인 결과 orders 테이블의 전체 행 수(7)와 주문번호 수(7)가 같아, 현재 데이터는 주문 한 건이 한 행으로 저장되어 있다. 따라서 `COUNT(*)`와 `COUNT(DISTINCT order_id)`의 결과는 같지만, 주문 단위 집계를 명확히 하기 위해 `DISTINCT`를 사용했다.