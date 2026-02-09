-- Создаём рабочую таблицу для анализа
CREATE TABLE firms_for_analysis AS
SELECT
    *,
    -- флаг: есть ли хотя бы 1 отзыв
    (review_count >= 1) AS has_any_review,

    -- флаг: есть ли "реальное" количество отзывов
    (review_count >= 5) AS has_enough_reviews,

    -- логарифм количества отзывов
    CASE WHEN review_count > 0 THEN LN(review_count) ELSE NULL END AS log_review_count

FROM firms_cleaned
WHERE
  -- исключаем совсем мусорные записи
    name IS NOT NULL
  AND name != ''
  AND adress IS NOT NULL
-- можно добавить ещё фильтры
-- AND rating IS NOT NULL
;

-- Проверяем, сколько осталось
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE has_site = true) AS with_site,
    COUNT(*) FILTER (WHERE has_site = false) AS without_site,
    COUNT(*) FILTER (WHERE review_count >= 5) AS with_5plus_reviews
FROM firms_for_analysis;

-- Добавляем флаги и логарифм
ALTER TABLE firms_for_analysis
    ADD COLUMN IF NOT EXISTS has_any_review     BOOLEAN,
    ADD COLUMN IF NOT EXISTS has_enough_reviews BOOLEAN,
    ADD COLUMN IF NOT EXISTS log_review_count   DOUBLE PRECISION;

UPDATE firms_for_analysis
SET
    has_any_review     = (review_count >= 1),
    has_enough_reviews = (review_count >= 5),
    log_review_count   = CASE WHEN review_count > 0 THEN LN(review_count) ELSE NULL END;

-- Финальная сводка по рабочей выборке
SELECT
    has_site,
    COUNT(*) AS n,
    COUNT(*) FILTER (WHERE has_any_review) AS with_reviews,
    COUNT(*) FILTER (WHERE has_enough_reviews) AS with_5plus,
    ROUND(AVG(review_count)::numeric, 1) AS avg_reviews,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY review_count) AS median_reviews,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    ROUND(AVG(log_review_count)::numeric, 2) AS avg_log_reviews
FROM firms_for_analysis
GROUP BY has_site
ORDER BY has_site DESC;