-- Example of creating custom size bins for histograms.

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
    WHEN CAST(price_per_serving AS float64) = 0 THEN '0'
    WHEN CAST(price_per_serving AS float64) BETWEEN 0
  AND 5 THEN '0 - 5'
    WHEN CAST(price_per_serving AS float64) BETWEEN 5 AND 10 THEN '05 - 10'
    WHEN CAST(price_per_serving AS float64) BETWEEN 10
  AND 20 THEN '10 - 20'
    WHEN CAST(price_per_serving AS float64) BETWEEN 20 AND 30 THEN '20 - 30'
    WHEN CAST(price_per_serving AS float64) BETWEEN 30
  AND 40 THEN '30 - 40'
    WHEN CAST(price_per_serving AS float64) BETWEEN 40 AND 50 THEN '40 - 50'
    WHEN CAST(price_per_serving AS float64) BETWEEN 50
  AND 60 THEN '50 - 60'
    WHEN CAST(price_per_serving AS float64) BETWEEN 60 AND 70 THEN '60 - 70'
    ELSE '70+'
  END AS price_per_serving_bin,
  COUNT(*) AS count_of_recipes
FROM
  temp_recipes
GROUP BY
  1
ORDER BY
  1 ASC