-- ============================================================
-- Problem 1: 고객 총 구매액 계산
-- ============================================================
-- 목표: 각 고객이 지금까지 구매한 총 구매액을 계산하기
-- 데이터베이스: my_shop2
-- 작성일: 2026-10-08
-- ============================================================

SELECT
    u.name AS user_name,
    SUM(o.quantity * p.price) AS total_purchase_amount
FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    INNER JOIN users u ON o.user_id = u.user_id
GROUP BY u.user_id, u.name
ORDER BY total_purchase_amount DESC;

-- ============================================================
-- 쿼리 설명
-- ============================================================
-- 1. FROM orders o
--    → orders 테이블을 기준으로 시작
--
-- 2. INNER JOIN products p ON o.product_id = p.product_id
--    → 각 주문에 해당하는 상품의 가격 정보 가져오기
--
-- 3. INNER JOIN users u ON o.user_id = u.user_id
--    → 각 주문의 고객 정보 가져오기
--
-- 4. SUM(o.quantity * p.price)
--    → 각 주문의 구매액(수량 × 가격)을 모두 더하기
--
-- 5. GROUP BY u.user_id, u.name
--    → 고객별로 묶어서 각 고객의 총액 계산
--
-- 6. ORDER BY total_purchase_amount DESC
--    → 총 구매액을 높은 순서부터 보여주기
-- ============================================================