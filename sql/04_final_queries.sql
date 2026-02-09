-- Процент фирм с высоким рейтингом (≥4.5)
SELECT
    has_site,
    COUNT(*) AS n,
    COUNT(*) FILTER (WHERE rating >= 4.5) AS high_rating_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE rating >= 4.5) / COUNT(*), 1) AS pct_high_rating
FROM firms_for_analysis
WHERE rating IS NOT NULL
GROUP BY has_site;

-- Фирмы с очень большим количеством отзывов (топ 1%)
SELECT
    has_site,
    COUNT(*) AS n,
    AVG(review_count) AS avg_in_top1pct
FROM (
         SELECT *,
                NTILE(100) OVER (ORDER BY review_count DESC) AS percentile
         FROM firms_for_analysis
         WHERE review_count > 0
     ) t
WHERE percentile = 1
GROUP BY has_site;