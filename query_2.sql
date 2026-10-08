-- ============================================================
-- Problem 2: 카테고리별 판매 현황 분석
-- ============================================================
-- 목표: 각 카테고리별로 총 판매액, 판매 건수, 평균 판매액 계산하기
-- 데이터베이스: my_shop2
-- 작성일: 2026-10-08
-- ============================================================

SELECT
    p.category AS category_name,
    SUM(o.quantity * p.price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.quantity * p.price) / COUNT(DISTINCT o.order_id) AS avg_sales_per_order
FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- ============================================================
-- 쿼리 설명
-- ============================================================
-- 1. FROM orders o
--    → orders 테이블을 기준으로 시작
--    → 각 주문 건을 base 데이터로 사용
--
-- 2. INNER JOIN products p ON o.product_id = p.product_id
--    → 각 주문에 해당하는 상품의 카테고리와 가격 정보 가져오기
--    → product_id를 기준으로 연결
--
-- 3. SUM(o.quantity * p.price) AS total_sales
--    → 각 주문의 판매액(수량 × 가격)을 모두 더하기
--    → 카테고리별로 집계됨
--
-- 4. COUNT(*) AS order_count
--    → 각 카테고리의 주문 건수 계산
--    → 같은 카테고리에 여러 주문이 있으면 모두 셈
--
-- 5. AVG(o.quantity * p.price) AS avg_sales_per_order
--    → 각 주문의 판매액의 평균값
--    → 주당 평균 판매액을 의미
--
-- 6. GROUP BY p.category
--    → 카테고리별로 데이터를 묶기
--    → 같은 카테고리의 주문들을 하나의 그룹으로 만들어
--    → 각 집계 함수가 카테고리별로 계산됨
--
-- 7. ORDER BY total_sales DESC
--    → 총 판매액을 높은 순서부터 보여주기
--    → 매출이 가장 높은 카테고리가 맨 위에 옴
-- ============================================================
