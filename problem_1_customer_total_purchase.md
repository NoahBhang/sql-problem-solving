# Problem 1: 고객 총 구매액 계산

## 📌 문제 정의

**요구사항:**
- 각 고객이 지금까지 구매한 총 구매액 계산하기

**데이터베이스:** my_shop2

**주어진 데이터:**
- orders 테이블: order_id, product_id, quantity, user_id
- products 테이블: product_id, price
- users 테이블: user_id, name

---

## 🔍 1단계: 문제 분석

**우리가 찾고 있는 것:**
1. 고객 이름 - users.name
2. 총 구매액 - SUM(orders.quantity × products.price)

**핵심 질문:**
- 어느 테이블을 기준으로 시작해야 하는가? → **orders 테이블** (구매 한 건 한 건이 집계의 기본 단위)
- 수량과 가격은 어디에 있는가? → 수량은 orders, 가격은 products
- 고객 이름은 어디에 있는가? → users

---

## 🗂 2단계: 테이블 연결 구조

```
orders.product_id → products.product_id   (가격 가져오기)
orders.user_id    → users.user_id         (고객 이름 가져오기)
```

---

## 💻 3단계: 쿼리 작성

```sql
SELECT
    u.name AS user_name,
    SUM(o.quantity * p.price) AS total_purchase_amount
FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u ON o.user_id = u.user_id
GROUP BY u.user_id, u.name
ORDER BY total_purchase_amount DESC;
```

---

## 📝 4단계: 쿼리 해설

1. **FROM orders o**: 구매 기록을 기준으로 시작합니다.
2. **INNER JOIN products**: 각 구매의 상품 가격을 가져옵니다.
3. **INNER JOIN users**: 각 구매의 고객 이름을 가져옵니다.
4. **SUM(o.quantity × p.price)**: 고객별 구매액(수량 × 가격)을 모두 더합니다.
5. **GROUP BY u.user_id, u.name**: 고객 단위로 묶어 총액을 계산합니다.
6. **ORDER BY ... DESC**: 총 구매액이 높은 고객부터 보여줍니다.

> 💡 **INNER JOIN의 의미:** 구매 이력이 없는 고객은 결과에서 빠집니다. 이 문제는 "구매한 고객의 총액"을 구하는 것이므로 맞는 선택입니다. 구매하지 않은 고객까지 포함하는 방법은 Problem 3a(LEFT JOIN)에서 다룹니다.
