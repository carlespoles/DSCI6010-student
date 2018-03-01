-- This is an example of creating bins for histograms, but the bins are of same size.
-- In this case we arbitrarely decide on a size of 0.25 (which depends on the nature of the data).
-- http://www.silota.com/docs/recipes/sql-histogram-summary-frequency-distribution.html

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
  -- FLOOR(image_appeal_score/0.25)*0.25 AS bucket_floor,
  CONCAT(CAST(FLOOR(image_appeal_score/0.25)*0.25 AS STRING), ' - ', CAST(FLOOR(image_appeal_score/0.25)*0.25 + 0.25 AS STRING)) AS bucket_range,
  COUNT(*) AS count_of_image_appeal_score
FROM
  temp_recipes
WHERE
  image_appeal_score IS NOT NULL
  AND image_appeal_score >=0
GROUP BY
  bucket_range
ORDER BY
  bucket_range ASC
