-- Another example of creating customs bins and using regular expressions to extract total_time.
-- Data source has this structure, for example: PT35M, PT1D, PT2H35M, etc (D for day, H for hour, M for minute, S for seconds).

WITH
  temp_recipes AS (
  SELECT
    t1.*
  FROM
    `firebase-wellio.recipes.imported_recipes` t1
  INNER JOIN (
    SELECT
      MAX(updated_at) AS last_update,
      id
    FROM
      `firebase-wellio.recipes.imported_recipes`
    GROUP BY
      id) t2
  ON
    t1.updated_at=last_update
    AND t1.id=t2.id )
SELECT
  CASE
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S')) - 1) AS int64)/60) = 0 THEN '0'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
            '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
            '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
            '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
            '0S')) - 1) AS int64)/60) BETWEEN 0
  AND 5 THEN '0 - 5'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S')) - 1) AS int64)/60) BETWEEN 5 AND 10 THEN '05 - 10'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
            '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
            '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
            '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
            '0S')) - 1) AS int64)/60) BETWEEN 10
  AND 20 THEN '10 - 20'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S')) - 1) AS int64)/60) BETWEEN 20 AND 30 THEN '20 - 30'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
            '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
            '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
            '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
            '0S')) - 1) AS int64)/60) BETWEEN 30
  AND 40 THEN '30 - 40'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S')) - 1) AS int64)/60) BETWEEN 40 AND 50 THEN '40 - 50'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
            '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
            '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
            '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
            '0S')) - 1) AS int64)/60) BETWEEN 50
  AND 60 THEN '50 - 60'
    WHEN (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),  '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),  '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),  '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),  '0S')) - 1) AS int64)/60) BETWEEN 60 AND 70 THEN '60 - 70'
    ELSE '70+'
  END AS total_time_preparation_bin,
  COUNT(*) AS count_of_recipes
FROM
  temp_recipes
GROUP BY
  1
ORDER BY
  1 ASC