# Problem 3a: 한 번도 주문하지 않은 고객 조회 (LEFT JOIN)

## 📌 문제 정의

**요구사항:**
- **모든 고객**을 조회하되, 각 고객이 한 번이라도 주문했는지 파악하기
- 주문이 없는 고객도 **명시적으로 포함**하기
- 각 고객별 주문 건수와 총 주문액을 보여주기

**데이터베이스:** my_shop2

**주어진 데이터:**
- users 테이블: user_id, name
- orders 테이블: order_id, product_id, quantity, user_id
- products 테이블: product_id, price

---

## 🔍 1단계: 문제 분석

이 문제를 풀기 위해 필요한 정보를 정리해봅시다.

**우리가 찾고 있는 것:**
1. **고객의 이름** - users.name
2. **주문 건수** - COUNT(orders.order_id)
3. **총 주문액** - SUM(orders.quantity × products.price)
4. **주문한 적이 있는가?** - orders가 NULL이면 주문 없음

**핵심 질문:**
- 어느 테이블을 기준으로 시작해야 하는가?
  → **users 테이블** (모든 고객을 보존해야 함)
- 주문 테이블과는 어떻게 연결할 것인가?
  → **LEFT JOIN** (users는 모두 남기고, orders는 매칭된 것만)
- 주문이 없는 고객의 주문 건수는?
  → **0** (또는 NULL)

---

## 🔍 2단계: 테이블 구조 확인

### users 테이블
```
user_id | name
--------|--------
1       | 김철수
2       | 이영희
3       | 박민준
4       | 최수진  (아직 주문 없음)
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

### products 테이블
```
product_id | price
-----------|------
10         | 50000
11         | 30000
12         | 80000
```

---

## 💡 3단계: 논리 구성 (LEFT JOIN 전략)

### 테이블 연결 방식

**왜 LEFT JOIN을 사용해야 하는가?**

기본키-외래키 관계의 수학적 함수 관점:
- **정의역 (Domain):** users 테이블의 모든 user_id (고객 전체)
- **공역 (Codomain):** orders 테이블의 모든 user_id (주문한 고객들)
- **치역 (Range):** 실제로 주문한 고객들의 부분집합

$$
\text{정의역} \supset \text{치역} \quad \text{(남는 고객이 존재)}
$$

LEFT JOIN은 정의역의 모든 원소를 보존합니다:

```
users (LEFT)
  ↓ LEFT JOIN
orders (RIGHT) on users.user_id = orders.user_id
  ↓
결과: users의 모든 행 + 매칭된 orders 행
     (매칭되지 않은 users 행은 orders 컬럼이 NULL)
```

### JOIN 후 구조

```
user_id | name    | order_id | quantity | product_id
--------|---------|----------|----------|------------
1       | 김철수   | 1        | 2        | 10
1       | 김철수   | 3        | 3        | 10
2       | 이영희   | 2        | 1        | 11
3       | 박민준   | 4        | 1        | 12
4       | 최수진   | NULL     | NULL     | NULL  ← 주문 없음
```

---

## 💡 4단계: 집계 전략 (GROUP BY와 NULL 처리)

**GROUP BY 선택:**

`GROUP BY users.user_id, users.name`

이유:
- 고객별로 묶어서 통계 계산
- 모든 고객이 결과에 나타나야 함

**집계 함수 선정:**

1. **주문 건수:** `COUNT(orders.order_id)`
   - orders.order_id가 NULL인 고객은 COUNT = 0
   - 주문이 있는 고객들의 주문 건수를 셈

2. **총 주문액:** `SUM(orders.quantity * products.price)`
   - 주문이 없는 고객은 SUM = NULL (0으로 변환 가능)
   - 또는 `COALESCE(SUM(...), 0)` 사용

---

## ✅ 5단계: 최종 쿼리 작성

```sql
SELECT 
    u.user_id,
    u.name AS customer_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.quantity * p.price), 0) AS total_amount
FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY u.user_id, u.name
ORDER BY order_count DESC, u.user_id;
```

**쿼리 해석:**

| 부분 | 역할 |
|------|------|
| `FROM users u` | 기준 테이블: 모든 고객 |
| `LEFT JOIN orders o` | orders의 매칭 행만 추가 (주문 없으면 NULL) |
| `LEFT JOIN products p` | products의 가격 정보 추가 |
| `COUNT(o.order_id)` | 주문 건수 (NULL은 제외되어 0이 됨) |
| `COALESCE(SUM(...), 0)` | 합계 (NULL을 0으로 변환) |
| `GROUP BY u.user_id, u.name` | 고객별로 묶기 |
| `ORDER BY order_count DESC` | 주문 많은 고객부터 정렬 |

---

## 📊 예상 결과

```
user_id | customer_name | order_count | total_amount
--------|---------------|-------------|---------------
1       | 김철수         | 2           | 260000
2       | 이영희         | 1           | 30000
3       | 박민준         | 1           | 80000
4       | 최수진         | 0           | 0
```

**해석:**
- 김철수: 2건 주문, 총 260,000원
- 이영희: 1건 주문, 총 30,000원
- 박민준: 1건 주문, 총 80,000원
- **최수진: 0건 주문, 0원** ← **LEFT JOIN으로만 나타남**

---

## 🎓 핵심 개념 정리

### LEFT JOIN의 본질

LEFT JOIN은 **"왼쪽 테이블(users)의 모든 행을 보존하되, 오른쪽 테이블(orders)의 매칭된 행만 추가"**합니다.

**수학적 관점:**

$$
\text{LEFT JOIN} = \text{정의역의 모든 원소를 보존하는 함수}
$$

- 정의역: users의 모든 행
- 함수: user_id를 기준으로 orders와 매칭
- 결과: 매칭되지 않은 행은 오른쪽 컬럼이 NULL

### NULL의 의미

```sql
order_id = NULL
↓
이 고객은 주문 기록이 없다
↓
COUNT(order_id)는 이 행을 제외하고 센다
↓
결과적으로 order_count = 0
```

### INNER JOIN과의 차이

| 연산 | 정의역 행 | 공역 행 | 매칭 안 된 정의역 | 매칭 안 된 공역 |
|------|---------|--------|------------------|-----------------|
| INNER JOIN | ✓ | ✓ | ✗ | ✗ |
| LEFT JOIN | ✓ | ✓ | ✓ (NULL) | ✗ |

---

## 💡 배운 점

1. **LEFT JOIN의 용도**
   - "모든 고객을 보고 싶지만, 주문 정보는 없을 수 있다"
   - 정의역의 모든 원소를 살려야 할 때

2. **함수 이론과의 연결**
   - 공역 ⊃ 치역인 경우, 매칭되지 않은 행도 표시됨
   - INNER JOIN은 치역만 보고, LEFT JOIN은 정의역 전체를 봄

3. **NULL 처리의 중요성**
   - COUNT()는 NULL을 제외하므로 0이 됨
   - SUM()은 NULL을 반환하므로 COALESCE()로 0으로 변환

4. **ORDER BY의 활용**
   - 주문 많은 순서부터 정렬하되
   - 주문이 없는 고객도 함께 표시
   - 비즈니스 의사결정에 도움 (고객 관계 관리)

---

## 🔗 함수 이론으로 정리하면

**LEFT JOIN의 수학적 정의:**

정의역 $D$ = users 테이블의 모든 user_id  
공역 $C$ = orders 테이블의 모든 user_id  
함수 $f: D \to C$의 결과

- **치역** $R \subset C$ (실제로 주문한 고객)
- **LEFT JOIN의 결과** = 정의역의 모든 원소 + 매칭된 공역의 원소

$$
\text{LEFT JOIN 결과} = D \cup_{\text{매칭}} C
$$

이는 **"정의역의 완전성을 보장하는 JOIN"** 입니다.
