-- Another example of using regular expressions.

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
  total_time,
  CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
        '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
        '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
        '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
        '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S')) - 1) AS int64) AS total_time_in_seconds,
  (CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
          '0D'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+D{1}"),
            '0D')) - 1) AS int64) * 86400 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
          '0H'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+H{1}"),
            '0H')) - 1) AS int64) * 3600 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
          '0M'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+M{1}"),
            '0M')) - 1) AS int64) * 60 + CAST(SUBSTR(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
          '0S'), 0, LENGTH(IfNULL(REGEXP_EXTRACT(total_time, r"[0-9]+S{1}"),
            '0S')) - 1) AS int64))/60 AS total_time_in_minutes
FROM
  temp_recipes
WHERE
  total_time LIKE 'PT%'