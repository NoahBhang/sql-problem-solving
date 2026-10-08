-- ============================================================
-- Problem 3b: 한 번도 팔리지 않은 상품 조회 (RIGHT JOIN)
-- ============================================================
-- 목표: 모든 상품을 조회하되, 팔린 적이 없는 상품도 포함하기
-- 데이터베이스: my_shop2
-- 작성일: 2026-10-08
-- 핵심 개념: RIGHT JOIN, NULL 처리, 함수 이론 (공역 보존)
-- ============================================================

-- 방법 1: RIGHT JOIN 사용
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

-- ============================================================
-- 방법 2: LEFT JOIN의 순서를 바꾼 방식 (가독성이 더 좋음)
-- ============================================================
/*
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
*/

-- ============================================================
-- 쿼리 설명
-- ============================================================
-- 1. FROM orders o
--    → orders 테이블을 시작점으로 (LEFT 테이블)
--    → 하지만 RIGHT JOIN이므로 products의 모든 행이 우선됨
--
-- 2. RIGHT JOIN products p ON o.product_id = p.product_id
--    → 오른쪽(products)의 모든 행을 유지하고, 왼쪽(orders)의 매칭 행만 추가
--    → 팔린 적이 없는 상품도 p 컬럼은 있지만 o 컬럼은 NULL
--    → 함수 이론: 공역(products)의 모든 원소를 보존
--
-- 3. COUNT(o.order_id) AS sales_count
--    → 각 상품의 판매 건수 계산
--    → NULL 값은 제외되므로 팔린 적 없는 상품은 0
--
-- 4. COALESCE(SUM(o.quantity), 0) AS total_quantity
--    → 각 상품의 판매 수량 합계
--    → 팔린 적 없는 상품의 SUM은 NULL이므로 COALESCE로 0 변환
--
-- 5. COALESCE(SUM(o.quantity * p.price), 0) AS total_sales_amount
--    → 각 상품의 총 판매액 계산
--    → 팔린 적 없는 상품은 0원
--
-- 6. GROUP BY p.product_id, p.category, p.price
--    → 상품별로 묶어서 집계 계산
--    → 모든 상품이 그룹으로 나타남 (판매 여부와 상관없이)
--
-- 7. ORDER BY sales_count DESC, p.product_id
--    → 판매 많은 상품부터 정렬
--    → 같은 판매 건수면 product_id로 정렬
--
-- ============================================================
-- LEFT JOIN과 RIGHT JOIN의 동치성
-- ============================================================
-- orders RIGHT JOIN products = products LEFT JOIN orders
--
-- 다음 두 쿼리는 동일한 결과:
-- SELECT ... FROM orders RIGHT JOIN products ...
-- SELECT ... FROM products LEFT JOIN orders ...
--
-- 가독성 측면: 기준 테이블(products)을 LEFT에 두는 것이 직관적
-- ============================================================
-- NULL 값의 의미
-- ============================================================
-- order_id = NULL → 이 상품은 판매된 적이 없음
-- quantity = NULL → 판매 수량이 없음
--
-- COUNT(NULL) = 제외됨 → sales_count = 0
-- SUM(NULL) = NULL → COALESCE로 0 변환
-- ============================================================
-- 비즈니스 활용
-- ============================================================
-- 1. 재고 관리: "팔리지 않은 상품 파악"
-- 2. 마케팅: "판매 부진 상품에 대한 프로모션 필요"
-- 3. 상품 성과 분석: "판매 순위별 상품 분류"
-- 4. 카탈로그 검토: "시간이 지나도 안 팔리는 상품 제거 검토"
-- ============================================================
