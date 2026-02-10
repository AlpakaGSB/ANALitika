-- =============================================================================
-- Готовые витрины и инсайты для отчёта
-- =============================================================================

-- 1. Основная сводка по группам (уже есть, но сохраним красиво)
CREATE OR REPLACE VIEW v_summary_groups AS
SELECT
    has_site,
    COUNT(*) AS n_firms,
    COUNT(*) FILTER (WHERE review_count = 0) AS zero_reviews,
    COUNT(*) FILTER (WHERE review_count >= 1) AS has_reviews,
    COUNT(*) FILTER (WHERE review_count >= 5) AS has_5plus_reviews,
    ROUND(AVG(review_count)::numeric, 1) AS avg_reviews,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY review_count) AS median_reviews,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    MAX(review_count) AS max_reviews
FROM firms_for_analysis
GROUP BY has_site;

SELECT * FROM v_summary_groups ORDER BY has_site DESC;


-- 2. Процент фирм с высоким рейтингом (≥4.5)
CREATE OR REPLACE VIEW v_high_rating AS
SELECT
    has_site,
    COUNT(*) AS total_with_rating,
    COUNT(*) FILTER (WHERE rating >= 4.5) AS high_rating_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE rating >= 4.5) / COUNT(*), 1) AS pct_high_rating
FROM firms_for_analysis
WHERE rating IS NOT NULL
GROUP BY has_site;

SELECT * FROM v_high_rating;


-- 3. Топ-10 фирм с наибольшим количеством отзывов в каждой группе
CREATE OR REPLACE VIEW v_top_reviews AS
SELECT
    has_site,
    name,
    review_count,
    rating,
    site,
    ROW_NUMBER() OVER (PARTITION BY has_site ORDER BY review_count DESC) AS rank_in_group
FROM firms_for_analysis
WHERE review_count > 0
ORDER BY has_site DESC, review_count DESC;


SELECT * FROM v_top_reviews WHERE rank_in_group <= 5;


-- 4. Распределение по количеству отзывов (бакеты) в процентах
CREATE OR REPLACE VIEW v_review_buckets AS
SELECT
    has_site,
    CASE
        WHEN review_count = 0                       THEN '0'
        WHEN review_count BETWEEN 1 AND 5           THEN '1–5'
        WHEN review_count BETWEEN 6 AND 20          THEN '6–20'
        WHEN review_count BETWEEN 21 AND 50         THEN '21–50'
        WHEN review_count BETWEEN 51 AND 100        THEN '51–100'
        WHEN review_count BETWEEN 101 AND 500       THEN '101–500'
        ELSE '>500'
        END AS bucket,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY has_site), 1) AS pct
FROM firms_for_analysis
GROUP BY has_site, bucket
ORDER BY has_site DESC, MIN(review_count);


SELECT * FROM v_review_buckets;