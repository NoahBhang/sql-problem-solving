# Problem 3c: 모든 주문과 매칭되지 않은 데이터 파악 (FULL OUTER JOIN)

## 📌 문제 정의

**요구사항:**
- 모든 주문 기록을 보여주되, **매칭되지 않은 고객/상품도 포함**하기
- 정상적으로 매칭된 주문: 고객 정보 + 상품 정보 모두 표시
- 이상 거래:
  - 존재하지 않는 고객의 주문 (user_id가 users에 없음)
  - 존재하지 않는 상품의 주문 (product_id가 products에 없음)
- 데이터 무결성 검사에 활용

**데이터베이스:** my_shop2

**주어진 데이터:**
- users 테이블: user_id, name
- products 테이블: product_id, category, price
- orders 테이블: order_id, product_id, quantity, user_id

---

## 🔍 1단계: 문제 분석

이 문제를 풀기 위해 필요한 정보를 정리해봅시다.

**우리가 찾고 있는 것:**
1. **주문 정보** - orders.order_id, orders.user_id, orders.product_id
2. **고객 정보** - users.name (있으면 표시, 없으면 NULL)
3. **상품 정보** - products.category, products.price (있으면 표시, 없으면 NULL)
4. **데이터 무결성** - NULL 값의 위치로 이상 거래 파악

**핵심 질문:**
- 모든 주문을 보존하면서 고객/상품 정보도 추가하려면?
  → **FULL OUTER JOIN** (양쪽 테이블의 모든 행 보존)
- 고객이 없는 주문이 있을까?
  → **외래키 제약**이 없다면 가능 (데이터베이스 무결성 검사 필요)
- 상품이 없는 주문이 있을까?
  → 마찬가지로 외래키 제약이 없다면 가능

---

## 🔍 2단계: 테이블 구조 확인

### users 테이블
```
user_id | name
--------|--------
1       | 김철수
2       | 이영희
3       | 박민준
```

### products 테이블
```
product_id | category | price
-----------|----------|------
10         | 전자제품 | 50000
11         | 의류     | 30000
12         | 전자제품 | 80000
```

### orders 테이블 (이상 거래 포함)
```
order_id | product_id | quantity | user_id
---------|-----------|----------|--------
1        | 10        | 2        | 1       (정상)
2        | 11        | 1        | 2       (정상)
3        | 10        | 3        | 1       (정상)
4        | 99        | 1        | 3       (❌ 상품 99는 없음)
5        | 12        | 2        | 999     (❌ 고객 999는 없음)
```

---

## 💡 3단계: 논리 구성 (FULL OUTER JOIN 전략)

### FULL OUTER JOIN의 본질

**FULL OUTER JOIN은 두 테이블의 모든 정보를 보존합니다:**

$$
\text{FULL OUTER JOIN} = \text{(LEFT OUTER JOIN)} \cup \text{(RIGHT OUTER JOIN)}
$$

- **왼쪽 테이블의 모든 행** (매칭되지 않으면 오른쪽 컬럼이 NULL)
- **오른쪽 테이블의 모든 행** (매칭되지 않으면 왼쪽 컬럼이 NULL)

### 테이블 연결 방식

**Step 1: orders와 users의 FULL OUTER JOIN**

```
orders (LEFT)
  ↓ FULL OUTER JOIN
users (RIGHT) on orders.user_id = users.user_id
  ↓
결과: 
- 정상 주문: order_id + user_id + name 모두 표시
- 존재하지 않는 고객의 주문: order_id + user_id 표시, name은 NULL
- 주문 없는 고객: name 표시, order_id + user_id는 NULL
```

**Step 2: Step1의 결과와 products의 FULL OUTER JOIN**

```
(Step1 결과) (LEFT)
  ↓ FULL OUTER JOIN
products (RIGHT) on orders.product_id = products.product_id
  ↓
결과:
- 정상 주문: 모든 정보 표시
- 존재하지 않는 상품의 주문: order_id + product_id 표시, 상품 정보 NULL
- 팔린 적 없는 상품: 상품 정보 표시, 주문 정보 NULL
```

### 예상 JOIN 결과

```
order_id | user_id | product_id | name    | category | price
---------|---------|-----------|---------|----------|------
1        | 1       | 10        | 김철수   | 전자제품 | 50000
2        | 2       | 11        | 이영희   | 의류     | 30000
3        | 1       | 10        | 김철수   | 전자제품 | 50000
4        | 3       | 99        | 박민준   | NULL     | NULL  ← ❌ 상품 없음
5        | 999     | 12        | NULL    | 전자제품 | 80000 ← ❌ 고객 없음
```

---

## 💡 4단계: 집계 전략 (NULL 처리와 데이터 분류)

**주문 데이터 분류:**

```sql
CASE
  WHEN users.user_id IS NOT NULL AND products.product_id IS NOT NULL THEN '정상 거래'
  WHEN users.user_id IS NULL THEN '존재하지 않는 고객의 주문'
  WHEN products.product_id IS NULL THEN '존재하지 않는 상품의 주문'
  ELSE '알 수 없는 오류'
END AS transaction_status
```

**정렬 우선순위:**
1. 정상 거래 먼저
2. 이상 거래 다음
3. 같은 카테고리 내에서는 order_id 순

---

## ✅ 5단계: 최종 쿼리 작성

```sql
SELECT 
    o.order_id,
    o.user_id,
    u.name AS customer_name,
    o.product_id,
    p.category,
    p.price,
    o.quantity,
    (o.quantity * p.price) AS order_amount,
    CASE
        WHEN u.user_id IS NOT NULL AND p.product_id IS NOT NULL THEN '정상 거래'
        WHEN u.user_id IS NULL THEN '❌ 존재하지 않는 고객'
        WHEN p.product_id IS NULL THEN '❌ 존재하지 않는 상품'
        ELSE '⚠️ 알 수 없는 오류'
    END AS transaction_status
FROM orders o
    FULL OUTER JOIN users u ON o.user_id = u.user_id
    FULL OUTER JOIN products p ON o.product_id = p.product_id
ORDER BY 
    CASE 
        WHEN u.user_id IS NOT NULL AND p.product_id IS NOT NULL THEN 1
        ELSE 2
    END,
    o.order_id;
```

**MySQL에서 FULL OUTER JOIN 사용 불가인 경우 (UNION 사용):**

```sql
SELECT 
    o.order_id,
    o.user_id,
    u.name AS customer_name,
    o.product_id,
    p.category,
    p.price,
    o.quantity,
    (o.quantity * p.price) AS order_amount,
    CASE
        WHEN u.user_id IS NOT NULL AND p.product_id IS NOT NULL THEN '정상 거래'
        WHEN u.user_id IS NULL THEN '❌ 존재하지 않는 고객'
        WHEN p.product_id IS NULL THEN '❌ 존재하지 않는 상품'
        ELSE '⚠️ 알 수 없는 오류'
    END AS transaction_status
FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    LEFT JOIN products p ON o.product_id = p.product_id
WHERE o.order_id IS NOT NULL

UNION

SELECT 
    NULL AS order_id,
    u.user_id,
    u.name AS customer_name,
    NULL AS product_id,
    NULL AS category,
    NULL AS price,
    NULL AS quantity,
    NULL AS order_amount,
    '주문 없는 고객' AS transaction_status
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE user_id = u.user_id)

UNION

SELECT 
    NULL AS order_id,
    NULL AS user_id,
    NULL AS customer_name,
    p.product_id,
    p.category,
    p.price,
    NULL AS quantity,
    NULL AS order_amount,
    '팔린 적 없는 상품' AS transaction_status
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE product_id = p.product_id);
```

---

## 📊 예상 결과

```
order_id | user_id | customer_name | product_id | category | price | quantity | order_amount | transaction_status
---------|---------|---------------|-----------|----------|-------|----------|--------------|--------------------
1        | 1       | 김철수         | 10        | 전자제품 | 50000 | 2        | 100000      | 정상 거래
2        | 2       | 이영희         | 11        | 의류     | 30000 | 1        | 30000       | 정상 거래
3        | 1       | 김철수         | 10        | 전자제품 | 50000 | 3        | 150000      | 정상 거래
4        | 3       | 박민준         | 99        | NULL     | NULL  | 1        | NULL        | ❌ 존재하지 않는 상품
5        | 999     | NULL           | 12        | 전자제품 | 80000 | 2        | NULL        | ❌ 존재하지 않는 고객
NULL     | NULL    | NULL           | 13        | 도서     | 15000 | NULL     | NULL        | 팔린 적 없는 상품
```

**해석:**
- 처음 3개 행: 모든 정보가 매칭된 **정상 거래**
- 4번 주문: 상품 ID 99는 products 테이블에 없음 (**데이터 무결성 오류**)
- 5번 주문: 고객 ID 999는 users 테이블에 없음 (**데이터 무결성 오류**)
- 마지막 행: 상품 13은 주문 기록이 없음 (**팔린 적 없는 상품**)

---

## 🎓 핵심 개념 정리

### FULL OUTER JOIN의 본질

FULL OUTER JOIN은 **"양쪽 테이블의 모든 행을 보존하는 JOIN"**입니다.

**수학적 관점:**

$$
\text{FULL OUTER JOIN} = (A \cap B) \cup (A - B) \cup (B - A)
$$

즉, 두 집합의 **합집합**을 만듭니다.

### NULL 값의 다양한 의미

```
users.user_id = NULL → 이 주문의 고객은 존재하지 않음 (데이터 오류)
users.name = NULL → 고객 정보를 찾을 수 없음

products.product_id = NULL → 이 주문의 상품은 존재하지 않음 (데이터 오류)
products.category = NULL → 상품 정보를 찾을 수 없음
products.price = NULL → 상품 가격을 계산할 수 없음
```

### 세 가지 JOIN의 결과 비교

| 행 유형 | INNER JOIN | LEFT JOIN | FULL OUTER JOIN |
|--------|-----------|-----------|-----------------|
| A와 B 모두 매칭 | ✓ | ✓ | ✓ |
| A만 존재 (B 미매칭) | ✗ | ✓ (B=NULL) | ✓ (B=NULL) |
| B만 존재 (A 미매칭) | ✗ | ✗ | ✓ (A=NULL) |

---

## 💡 배운 점

1. **FULL OUTER JOIN의 용도**
   - 두 테이블의 전체 데이터를 모두 보고 싶을 때
   - 데이터 무결성 검사 (NULL 값으로 오류 감지)
   - 양쪽 테이블의 누락된 데이터 파악

2. **함수 이론과의 연결**
   - 정의역과 공역이 다를 때, 양쪽의 불일치를 모두 표시
   - 함수의 **일대일 대응(Bijection)** 실패 시 FULL OUTER JOIN으로 확인 가능

3. **데이터 무결성 검사**
   - 외래키 제약이 없는 경우에 유용
   - 손상된 참조 관계를 발견할 수 있음

4. **비즈니스 관점**
   - 이상 거래 탐지 (고객/상품 정보 누락)
   - 팔리지 않은 상품 + 주문하지 않은 고객 동시 파악

---

## 🔗 함수 이론으로 정리하면

**FULL OUTER JOIN의 수학적 정의:**

정의역 $D$ = orders 테이블의 모든 user_id  
공역1 $C_1$ = users 테이블의 모든 user_id  
공역2 $C_2$ = products 테이블의 모든 product_id

FULL OUTER JOIN의 결과는:

$$
(D \cup C_1) \cup C_2
$$

즉, **"정의역과 양쪽 공역의 완전한 합집합"**을 만듭니다.

이는 **"양쪽의 일관성을 동시에 검증하는 JOIN"**입니다.

---

## 📝 Problem 3 전체 요약

| 문제 | JOIN 종류 | 보존되는 테이블 | 용도 |
|------|----------|---------------|----|
| 3a | LEFT | users (고객) | "주문하지 않은 고객 파악" |
| 3b | RIGHT | products (상품) | "팔리지 않은 상품 파악" |
| 3c | FULL OUTER | 모든 테이블 | "데이터 무결성 검사" |

세 문제를 통해 **외부조인의 본질**—각 테이블의 완전성을 보장하는 방식—을 이해할 수 있습니다.
