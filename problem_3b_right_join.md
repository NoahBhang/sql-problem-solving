# Problem 3b: 한 번도 팔리지 않은 상품 조회 (RIGHT JOIN)

## 📌 문제 정의

**요구사항:**
- **모든 상품**을 조회하되, 팔린 적이 없는 상품도 파악하기
- 팔린 적이 없는 상품도 **명시적으로 포함**하기
- 각 상품별 판매 건수와 총 판매액을 보여주기

**데이터베이스:** my_shop2

**주어진 데이터:**
- products 테이블: product_id, category, price
- orders 테이블: order_id, product_id, quantity, user_id

---

## 🔍 1단계: 문제 분석

이 문제를 풀기 위해 필요한 정보를 정리해봅시다.

**우리가 찾고 있는 것:**
1. **상품 정보** - products.product_id, products.category, products.price
2. **판매 건수** - COUNT(orders.order_id)
3. **총 판매액** - SUM(orders.quantity × products.price)
4. **팔린 적이 있는가?** - orders가 NULL이면 팔린 적 없음

**핵심 질문:**
- 어느 테이블을 기준으로 시작해야 하는가?
  → **products 테이블** (모든 상품을 보존해야 함)
- 주문 테이블과는 어떻게 연결할 것인가?
  → **RIGHT JOIN** 또는 **LEFT JOIN의 순서 바꿈** (products는 모두 남기고, orders는 매칭된 것만)
- 팔린 적이 없는 상품의 판매 건수는?
  → **0** (또는 NULL)

---

## 🔍 2단계: 테이블 구조 확인

### products 테이블
```
product_id | category | price
-----------|----------|------
10         | 전자제품 | 50000
11         | 의류     | 30000
12         | 전자제품 | 80000
13         | 도서     | 15000  (아직 팔리지 않음)
```

### orders 테이블
```
order_id | product_id | quantity | user_id
---------|-----------|----------|--------
1        | 10        | 2        | 1
2        | 11        | 1        | 2
3        | 10        | 3        | 1
4        | 12        | 1        | 3
```

---

## 💡 3단계: 논리 구성 (RIGHT JOIN 전략)

### 테이블 연결 방식

**왜 RIGHT JOIN을 사용해야 하는가?**

기본키-외래키 관계의 수학적 함수 관점:
- **정의역 (Domain):** orders 테이블의 모든 product_id (주문된 상품들)
- **공역 (Codomain):** products 테이블의 모든 product_id (전체 상품 카탈로그)
- **치역 (Range):** 실제로 판매된 상품들의 부분집합

$$
\text{공역} \supset \text{치역} \quad \text{(팔리지 않은 상품이 존재)}
$$

RIGHT JOIN은 공역의 모든 원소를 보존합니다:

```
orders (LEFT)
  ↓ RIGHT JOIN
products (RIGHT) on orders.product_id = products.product_id
  ↓
결과: products의 모든 행 + 매칭된 orders 행
     (매칭되지 않은 products 행은 orders 컬럼이 NULL)
```

### JOIN 후 구조

```
product_id | category | price | order_id | quantity
-----------|----------|-------|----------|----------
10         | 전자제품 | 50000 | 1        | 2
10         | 전자제품 | 50000 | 3        | 3
11         | 의류     | 30000 | 2        | 1
12         | 전자제품 | 80000 | 4        | 1
13         | 도서     | 15000 | NULL     | NULL  ← 팔리지 않음
```

---

## 💡 4단계: 집계 전략 (GROUP BY와 NULL 처리)

**GROUP BY 선택:**

`GROUP BY products.product_id, products.category, products.price`

이유:
- 상품별로 묶어서 통계 계산
- 모든 상품이 결과에 나타나야 함
- 상품 정보(category, price)도 함께 표시

**집계 함수 선정:**

1. **판매 건수:** `COUNT(orders.order_id)`
   - orders.order_id가 NULL인 상품은 COUNT = 0
   - 판매된 상품들의 판매 건수를 셈

2. **총 판매액:** `SUM(orders.quantity * products.price)`
   - 팔린 적이 없는 상품은 SUM = NULL (0으로 변환 가능)
   - 또는 `COALESCE(SUM(...), 0)` 사용

---

## ✅ 5단계: 최종 쿼리 작성

```sql
SELECT 
    p.product_id,
    p.category,
    p.price,
    COUNT(o.order_id) AS sales_count,
    COALESCE(SUM(o.quantity), 0) AS total_quantity,
    COALESCE(SUM(o.quantity * p.price), 0) AS total_sales_amount
FROM orders o
    RIGHT JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.category, p.price
ORDER BY sales_count DESC, p.product_id;
```

**또는 LEFT JOIN의 순서를 바꾼 방식:**

```sql
SELECT 
    p.product_id,
    p.category,
    p.price,
    COUNT(o.order_id) AS sales_count,
    COALESCE(SUM(o.quantity), 0) AS total_quantity,
    COALESCE(SUM(o.quantity * p.price), 0) AS total_sales_amount
FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.category, p.price
ORDER BY sales_count DESC, p.product_id;
```

**쿼리 해석:**

| 부분 | 역할 |
|------|------|
| `FROM products p` (LEFT JOIN) 또는 `FROM orders o RIGHT JOIN products p` | 기준 테이블: 모든 상품 |
| `LEFT/RIGHT JOIN orders o` | orders의 매칭 행만 추가 (판매 없으면 NULL) |
| `COUNT(o.order_id)` | 판매 건수 (NULL은 제외되어 0이 됨) |
| `COALESCE(SUM(o.quantity), 0)` | 판매 수량의 합 (NULL을 0으로 변환) |
| `COALESCE(SUM(o.quantity * p.price), 0)` | 총 판매액 (NULL을 0으로 변환) |
| `GROUP BY p.product_id, p.category, p.price` | 상품별로 묶기 |
| `ORDER BY sales_count DESC` | 판매 많은 상품부터 정렬 |

---

## 📊 예상 결과

```
product_id | category | price | sales_count | total_quantity | total_sales_amount
-----------|----------|-------|-------------|----------------|--------------------
10         | 전자제품 | 50000 | 2           | 5              | 250000
12         | 전자제품 | 80000 | 1           | 1              | 80000
11         | 의류     | 30000 | 1           | 1              | 30000
13         | 도서     | 15000 | 0           | 0              | 0
```

**해석:**
- 상품 10 (전자제품, 50,000원): 2건 판매, 수량 5개, 총 250,000원
- 상품 12 (전자제품, 80,000원): 1건 판매, 수량 1개, 총 80,000원
- 상품 11 (의류, 30,000원): 1건 판매, 수량 1개, 총 30,000원
- **상품 13 (도서, 15,000원): 0건 판매, 수량 0개, 0원** ← **RIGHT JOIN으로만 나타남**

---

## 🎓 핵심 개념 정리

### RIGHT JOIN의 본질

RIGHT JOIN은 **"오른쪽 테이블(products)의 모든 행을 보존하되, 왼쪽 테이블(orders)의 매칭된 행만 추가"** 합니다.

**수학적 관점:**

$$
\text{RIGHT JOIN} = \text{공역의 모든 원소를 보존하는 함수}
$$

- 공역: products의 모든 행
- 함수: product_id를 기준으로 orders와 매칭
- 결과: 매칭되지 않은 행은 왼쪽 컬럼이 NULL

### NULL의 의미

```sql
order_id = NULL
↓
이 상품은 판매된 적이 없다
↓
COUNT(order_id)는 이 행을 제외하고 센다
↓
결과적으로 sales_count = 0
```

### LEFT JOIN과 RIGHT JOIN의 차이

| 연산 | 왼쪽 테이블 | 오른쪽 테이블 | 왼쪽 미매칭 | 오른쪽 미매칭 |
|------|-----------|-------------|------------|------------|
| INNER JOIN | ✓ | ✓ | ✗ | ✗ |
| LEFT JOIN | ✓ | ✓ | ✓ (NULL) | ✗ |
| RIGHT JOIN | ✓ | ✓ | ✗ | ✓ (NULL) |

---

## 💡 배운 점

1. **RIGHT JOIN의 용도**
   - "모든 상품을 보고 싶지만, 주문 정보는 없을 수 있다"
   - 공역의 모든 원소를 살려야 할 때

2. **함수 이론과의 연결**
   - 정의역 ⊂ 공역인 경우, 매칭되지 않은 행도 표시됨
   - INNER JOIN은 치역만 보고, RIGHT JOIN은 공역 전체를 봄

3. **LEFT와 RIGHT의 상호 변환성**
   - `LEFT JOIN` = `RIGHT JOIN`의 테이블 순서 반대
   - `orders RIGHT JOIN products` = `products LEFT JOIN orders`
   - 가독성 측면에서는 기준 테이블을 왼쪽에 두는 것이 직관적

4. **비즈니스 관점에서의 활용**
   - 재고 관리: "팔리지 않은 상품 파악"
   - 상품 성과 분석: "판매량 부진 상품 식별"
   - 마케팅: "프로모션이 필요한 상품 목록"

---

## 🔗 함수 이론으로 정리하면

**RIGHT JOIN의 수학적 정의:**

정의역 $D$ = orders 테이블의 모든 product_id  
공역 $C$ = products 테이블의 모든 product_id  
함수 $f: D \to C$의 결과

- **치역** $R \subset C$ (실제로 판매된 상품)
- **RIGHT JOIN의 결과** = 매칭된 정의역의 원소 + 공역의 모든 원소

$$
\text{RIGHT JOIN 결과} = D_{\text{매칭}} \cup C
$$

이는 **"공역의 완전성을 보장하는 JOIN"** 입니다.

---

## 📝 LEFT JOIN과의 비교

**Problem 3a (LEFT JOIN):**
- 기준: 모든 고객 보존 (정의역)
- 목표: 주문 여부 파악

**Problem 3b (RIGHT JOIN):**
- 기준: 모든 상품 보존 (공역)
- 목표: 판매 여부 파악

두 문제의 차이는 **"어느 테이블의 완전성을 보장하는가"** 입니다.
