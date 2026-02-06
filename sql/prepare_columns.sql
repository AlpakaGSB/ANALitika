CREATE TABLE firms_cleaned (
                               id              SERIAL PRIMARY KEY,
                               href            TEXT,
                               name            TEXT,
                               adress          TEXT,
                               phone           TEXT,
                               rating          NUMERIC(3,1),
                               review_count    INTEGER,
                               has_site        BOOLEAN,
                               site            TEXT,
                               average_bill    TEXT,
                               rate_orig       TEXT,
                               rate_count_orig TEXT,
                               created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO firms_cleaned (
    href, name, adress, phone,
    rating, review_count, has_site, site,
    average_bill,
    rate_orig, rate_count_orig
)
SELECT
    href,
    name,
    adress,
    phone,

    -- рейтинг
    CASE
        WHEN rate ~ '^[0-9]+([.,][0-9])?$'
            THEN REPLACE(rate, ',', '.')::NUMERIC(3,1)
        ELSE NULL
        END AS rating,

    -- количество отзывов — исправленный вариант
    CASE
        WHEN rate_count ~* 'Ещё нет|нет отзывов|отсутствует|Нет|0'
            THEN 0

        WHEN rate_count ~ '^[0-9]+'
            THEN COALESCE(
                (regexp_match(rate_count, '^([0-9]+)'))[1]::INTEGER,
                0
                 )

        ELSE 0
        END AS review_count,

    (TRIM(site) != ''
        AND site IS NOT NULL
        AND site != 'null'
        AND site != 'None'
        AND LENGTH(TRIM(site)) > 3) AS has_site,

    site,
    average_bill,

    rate           AS rate_orig,
    rate_count     AS rate_count_orig

FROM firms;