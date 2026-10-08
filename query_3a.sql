-- ============================================================
-- Problem 3a: 한 번도 주문하지 않은 고객 조회 (LEFT JOIN)
-- ============================================================
-- 목표: 모든 고객을 조회하되, 주문하지 않은 고객도 포함하기
-- 데이터베이스: my_shop2
-- 작성일: 2026-10-08
-- 핵심 개념: LEFT JOIN, NULL 처리, 함수 이론 (정의역 보존)
-- ============================================================

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

-- ============================================================
-- 쿼리 설명
-- ============================================================
-- 1. FROM users u
--    → users 테이블을 기준으로 시작 (모든 고객 보존)
--
-- 2. LEFT JOIN orders o ON u.user_id = o.user_id
--    → 왼쪽(users)의 모든 행을 유지하고, 오른쪽(orders)의 매칭 행만 추가
--    → 주문이 없는 고객도 u 컬럼은 있지만 o 컬럼은 NULL
--    → 함수 이론: 정의역(users)의 모든 원소를 보존
--
-- 3. LEFT JOIN products p ON o.product_id = p.product_id
--    → orders와 products를 LEFT JOIN으로 가격 정보 추가
--    → order_id가 NULL이면 price도 NULL
--
-- 4. COUNT(o.order_id) AS order_count
--    → 각 고객의 주문 건수 계산
--    → NULL 값은 제외되므로 주문 없는 고객은 0
--
-- 5. COALESCE(SUM(o.quantity * p.price), 0) AS total_amount
--    → 각 고객의 총 주문액 계산
--    → 주문이 없는 고객의 SUM 결과는 NULL이므로 COALESCE로 0으로 변환
--
-- 6. GROUP BY u.user_id, u.name
--    → 고객별로 묶어서 집계 계산
--    → 모든 고객이 그룹으로 나타남 (주문 유무와 상관없이)
--
-- 7. ORDER BY order_count DESC, u.user_id
--    → 주문 많은 고객부터 정렬
--    → 같은 주문 건수면 user_id로 정렬
--
-- ============================================================
-- LEFT JOIN vs INNER JOIN 비교
-- ============================================================
-- INNER JOIN:  users ⊂ orders (주문한 고객만)
-- LEFT JOIN:   users 전체 (주문 여부와 상관없이)
--
-- 함수 이론 관점:
-- - INNER JOIN: 치역(실제 매칭)만 반환
-- - LEFT JOIN:  정의역(모든 왼쪽 테이블) 전체를 보존
--
-- ============================================================
-- NULL 값의 의미
-- ============================================================
-- order_id = NULL → 이 고객은 주문 기록이 없음
-- quantity = NULL → 주문 기록이 없으므로 수량도 없음
-- price = NULL   → 상품 정보도 매칭되지 않음
--
-- COUNT(NULL) = 제외됨 → order_count = 0
-- SUM(NULL) = NULL → COALESCE로 0 변환
-- ============================================================
