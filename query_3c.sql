-- ============================================================
-- Problem 3c: 데이터 무결성 검사 (FULL OUTER JOIN)
-- ============================================================
-- 목표: 모든 주문, 매칭되지 않은 고객, 매칭되지 않은 상품을 모두 표시하기
-- 데이터베이스: my_shop2
-- 작성일: 2026-10-08
-- 핵심 개념: FULL OUTER JOIN, NULL 처리, 데이터 무결성 검사
-- ============================================================

-- ============================================================
-- 방법 1: FULL OUTER JOIN 사용 (PostgreSQL, Oracle 등)
-- MySQL 8.0.31+에서도 지원됨
-- ============================================================
SELECT
    o.order_id,
    o.user_id,
    u.name AS customer_name,
    o.product_id,
    p.category,
    p.price,
    o.quantity,
    CASE
        WHEN o.quantity IS NOT NULL AND p.price IS NOT NULL
        THEN o.quantity * p.price
        ELSE NULL
    END AS order_amount,
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

-- ============================================================
-- 방법 2: UNION을 사용한 구현 (MySQL, SQLite 등 호환)
-- FULL OUTER JOIN을 지원하지 않는 데이터베이스에서 사용
-- ============================================================
/*
SELECT
    o.order_id,
    o.user_id,
    u.name AS customer_name,
    o.product_id,
    p.category,
    p.price,
    o.quantity,
    CASE
        WHEN o.quantity IS NOT NULL AND p.price IS NOT NULL
        THEN o.quantity * p.price
        ELSE NULL
    END AS order_amount,
    CASE
        WHEN u.user_id IS NOT NULL AND p.product_id IS NOT NULL THEN '정상 거래'
        WHEN u.user_id IS NULL THEN '❌ 존재하지 않는 고객'
        WHEN p.product_id IS NULL THEN '❌ 존재하지 않는 상품'
        ELSE '⚠️ 알 수 없는 오류'
    END AS transaction_status
FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    LEFT JOIN products p ON o.product_id = p.product_id

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
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE product_id = p.product_id)
ORDER BY
    CASE
        WHEN transaction_status = '정상 거래' THEN 1
        ELSE 2
    END,
    order_id;
*/

-- ============================================================
-- 쿼리 설명
-- ============================================================
-- 1. FROM orders o
--    → orders 테이블을 시작점으로 (모든 주문 데이터 보존)
--
-- 2. FULL OUTER JOIN users u ON o.user_id = u.user_id
--    → 양쪽(orders와 users)의 모든 행을 유지
--    → 고객이 없는 주문: u 컬럼이 NULL
--    → 주문 없는 고객: o 컬럼이 NULL
--    → 함수 이론: 정의역과 공역의 합집합 보존
--
-- 3. FULL OUTER JOIN products p ON o.product_id = p.product_id
--    → 양쪽(orders와 products)의 모든 행을 유지
--    → 상품이 없는 주문: p 컬럼이 NULL
--    → 팔리지 않은 상품: o 컬럼이 NULL
--
-- 4. CASE WHEN o.quantity IS NOT NULL AND p.price IS NOT NULL
--       THEN o.quantity * p.price
--       ELSE NULL
--    END AS order_amount
--    → 주문액 계산
--    → 주문이나 상품 정보가 NULL이면 order_amount도 NULL
--    → 이상 거래 식별에 활용
--
-- 5. CASE ~ END AS transaction_status
--    → 거래 상태 분류
--    → u.user_id IS NOT NULL AND p.product_id IS NOT NULL: 정상 거래
--    → u.user_id IS NULL: 존재하지 않는 고객의 주문 (데이터 오류)
--    → p.product_id IS NULL: 존재하지 않는 상품의 주문 (데이터 오류)
--
-- 6. ORDER BY CASE ~ END
--    → 정상 거래를 먼저 표시
--    → 이상 거래는 나중에 표시
--    → 같은 카테고리 내에서는 order_id로 정렬
--
-- ============================================================
-- LEFT JOIN과 FULL OUTER JOIN의 차이
-- ============================================================
-- LEFT JOIN:  users의 모든 행 보존 (주문 여부와 상관없이)
-- RIGHT JOIN: products의 모든 행 보존 (판매 여부와 상관없이)
-- FULL OUTER JOIN: 양쪽의 모든 행 보존 (데이터 무결성 검사용)
--
-- 함수 이론 관점:
-- - LEFT JOIN: 정의역 완전성 보장
-- - RIGHT JOIN: 공역 완전성 보장
-- - FULL OUTER JOIN: 양쪽의 완전성 동시 보장
--
-- ============================================================
-- NULL 값의 의미
-- ============================================================
-- o.order_id = NULL
--   → 이 행은 고객이나 상품 정보 없이 생성된 항목
--   → users 또는 products 테이블에만 존재하는 행
--
-- u.user_id = NULL
--   → 이 주문의 고객은 users 테이블에 없음 (데이터 오류)
--   → 외래키 제약이 없을 경우 발생 가능
--
-- p.product_id = NULL
--   → 이 주문의 상품은 products 테이블에 없음 (데이터 오류)
--   → 외래키 제약이 없을 경우 발생 가능
--
-- o.quantity * p.price = NULL
--   → 주문액을 계산할 수 없음 (데이터 결손)
--   → 이상 거래 식별에 활용
--
-- ============================================================
-- 비즈니스 활용
-- ============================================================
-- 1. 데이터 무결성 검사
--    → 외래키 제약 없이 손상된 참조 관계 감지
--    → 고아 레코드(orphan records) 식별
--
-- 2. 이상 거래 탐지
--    → 고객 정보 누락 주문 발견
--    → 상품 정보 누락 주문 발견
--
-- 3. 마스터 데이터 관리
--    → 주문 없는 고객 파악 (고객 이탈, 테스트 계정 등)
--    → 팔린 적 없는 상품 파악 (불필요한 상품, 재고 정리 대상)
--
-- 4. 데이터 품질 모니터링
--    → 정기적인 무결성 검사 쿼리로 활용
--    → 데이터 정제 및 마이그레이션 작업에 유용
--
-- ============================================================
-- FULL OUTER JOIN vs UNION 성능 비교
-- ============================================================
-- FULL OUTER JOIN:
--   장점: 간단한 문법, 가독성 좋음
--   단점: PostgreSQL, Oracle 같은 고급 DB에서만 지원
--   성능: 최적화된 실행 계획
--
-- UNION:
--   장점: 모든 SQL 표준 준수 데이터베이스에서 사용 가능
--   단점: 쿼리가 길고 복잡함, 세 개의 SELECT 실행
--   성능: UNION의 중복 제거 오버헤드 (UNION ALL 사용 권장)
--
-- 권장사항:
-- - 고급 DB (PostgreSQL, Oracle): FULL OUTER JOIN 사용
-- - 호환성 중요 (MySQL, SQLite): UNION 사용
--
-- ============================================================
-- 스콧 영의 울트라 러닝 방식으로 배우기
-- ============================================================
-- 1. 핵심 개념 파악: FULL OUTER JOIN은 양쪽의 모든 정보를 보존
-- 2. 구체적 사례: 고객/상품 정보 누락인 이상 거래 찾기
-- 3. 함수 이론 연결: 정의역 ∪ 공역의 모든 원소를 결과에 포함
-- 4. 실전 활용: 데이터 품질 모니터링, 데이터 정제
-- 5. 패턴 인식:
--    - LEFT + RIGHT의 합집합 = FULL OUTER JOIN 개념
--    - NULL 값의 위치로 어느 테이블에서 누락되었는지 즉시 판단
--    - transaction_status로 자동 분류 → 대시보드화 가능
--
-- ============================================================
