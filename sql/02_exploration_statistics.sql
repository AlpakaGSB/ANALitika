-- =============================================================================
-- 03_exploration_statistics.sql
-- Основная статистика по всей таблице и по группам has_site
-- =============================================================================

-- 1. Общая статистика по количеству отзывов (все записи)
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER ( WHERE review_count = 0 ) AS zero_reviews,
    COUNT(*) FILTER ( WHERE review_count >= 1 ) AS has_at_least_one_review,
    COUNT(*) FILTER ( WHERE review_count >= 5 ) AS has_5_or_more,
    MIN(review_count) AS min_reviews,
    MAX(review_count) AS max_reviews,
    round(avg(review_count)::numeric, 1) AS avg_reviews,
    percentile_cont(0.5) within group ( order by review_count ) AS median_reviews,
    percentile_cont(0.90) within group ( order by review_count ) AS p9_reviews,
    percentile_cont(0.95) within group ( order by review_count ) AS p95_reviews,
    percentile_cont(0.99) within group ( order by review_count ) AS p99_reviews
FROM firms_cleaned;

-- 2. Статистика отдельно для фирм с сайтом и без сайта
SELECT
    has_site,
    count(*) AS n_firms,
    count(*) FILTER ( WHERE review_count = 0 ) AS zero_reviews,
    count(*) FILTER ( WHERE review_count >= 1 ) AS has_reviews,
    round(avg(review_count)::numeric, 1) AS avg_reviews,
    percentile_cont(0.5) within group ( order by review_count ) AS median_reviews,
    percentile_cont(0.90) within group ( order by review_count ) AS p9,
    percentile_cont(0.95) within group ( order by review_count ) AS p95,
    percentile_cont(0.99) within group ( order by review_count ) AS p99,
    MAX(review_count) AS max_reviews
FROM firms_cleaned
GROUP BY has_site
ORDER BY has_site DESC;

-- 3. Топ-30 фирм по количеству отзывов (чтобы увидеть реальных лидеров)
SELECT
    row_number() over (ORDER BY review_count DESC) AS rank,
    name,
    rating,
    review_count,
    has_site,
    site
FROM firms_cleaned
ORDER BY review_count DESC NULLS LAST
LIMIT 30;

-- 4. Топ-10 фирм с самым низким рейтингом (но хотя бы 10 отзывов)
SELECT
    name,
    rating,
    review_count,
    has_site,
    site
FROM firms_cleaned
WHERE review_count >= 10
ORDER BY rating ASC
LIMIT 15;

-- 5. Распределение количества отзывов по диапазонам (бакеты)
SELECT
    CASE
        WHEN review_count = 0 THEN '0'
        WHEN review_count BETWEEN 1 AND 5           THEN '1–5'
        WHEN review_count BETWEEN 6 AND 20          THEN '6–20'
        WHEN review_count BETWEEN 21 AND 50         THEN '21–50'
        WHEN review_count BETWEEN 51 AND 100        THEN '51–100'
        WHEN review_count BETWEEN 101 AND 500       THEN '101–500'
        WHEN review_count BETWEEN 501 AND 2000      THEN '501–2000'
        ELSE '> 2000'
    END AS review_bucket,
    count(*) AS firm_count,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS percent
FROM firms_cleaned
GROUP BY review_bucket
ORDER BY min(review_count);