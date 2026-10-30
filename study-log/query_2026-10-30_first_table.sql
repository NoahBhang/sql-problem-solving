-- 2026-10-30: my_shop.sample 첫 테이블 실습
-- 실행할 때는 한 문장씩 선택해서 실행한다.

CREATE DATABASE my_shop;

USE my_shop;

CREATE TABLE sample (
    product_id     INT PRIMARY KEY,
    name           VARCHAR(100),
    price          INT,
    stock_quantity INT,
    release_date   DATE
);

-- 구조 확인
DESC my_shop.sample;

-- 데이터 확인 (처음에는 0 rows)
SELECT *
FROM my_shop.sample;

-- 데이터 입력
INSERT INTO my_shop.sample (product_id, name, price, stock_quantity, release_date)
VALUES
    (1, '키보드', 35000, 120, '2026-01-15'),
    (2, '마우스', 25000, 200, '2026-02-01'),
    (3, '모니터', 280000, 45, '2026-03-10');

-- 입력 후 확인 (3 rows)
SELECT *
FROM my_shop.sample;
