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
--    → 각 주문 상품 행을 기본 데이터로 사용
--
-- 2. INNER JOIN products p ON o.product_id = p.product_id
--    → 각 주문 상품의 카테고리와 가격 정보 가져오기
--    → product_id를 기준으로 연결
--
-- 3. SUM(o.quantity * p.price) AS total_sales
--    → 각 주문 상품의 판매액(수량 × 가격)을 모두 더하기
--    → 카테고리별로 집계됨
--
-- 4. COUNT(DISTINCT o.order_id) AS order_count
--    → 카테고리별 주문 건수 계산
--    → 한 주문에 같은 카테고리 상품이 여러 줄 있어도 주문번호로 한 번만 셈
--    → COUNT(*)를 쓰면 상품 행 수가 세어지므로 주문 건수와 달라짐
--
-- 5. SUM(o.quantity * p.price) / COUNT(DISTINCT o.order_id) AS avg_sales_per_order
--    → 주문당 평균 판매액 = 카테고리 총 판매액 ÷ 주문 건수
--    → 행 단위 평균(AVG)이 아니라 주문 단위 평균을 구하기 위한 계산
--
-- 6. GROUP BY p.category
--    → 카테고리별로 데이터를 묶기
--    → 집계 함수들이 카테고리별로 계산됨
--
-- 7. ORDER BY total_sales DESC
--    → 총 판매액을 높은 순서부터 보여주기
--    → 매출이 가장 높은 카테고리가 맨 위에 옴
-- ============================================================