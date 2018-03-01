-- Example of creating customs bins along and regular expressions with data that is in the form of a list in a BigQuery table.
-- We are interested in Calories.
-- Data looks like this (1 row of data):

-- Calories 830.5	 
-- Calories from Fat 235	 
-- Total Fat 26.2 g	 
-- Saturated Fat 8.3 g	 
-- Cholesterol 75.1 mg	 
-- Sodium 1251.3 mg	 
-- Total Carbohydrate 103.2 g	 
-- Dietary Fiber 5.4 g	 
-- Sugars 5.3 g	 
-- Protein 43 g

-- https://firebase.googleblog.com/2017/03/bigquery-tip-unnest-function.html

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
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),  '0') AS float64)) = 0 THEN '0'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),
        '0') AS float64)) BETWEEN 0
  AND 50 THEN '0 - 50'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),  '0') AS float64)) BETWEEN 50 AND 100 THEN '0050 - 100'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),
        '0') AS float64)) BETWEEN 100
  AND 300 THEN '0100 - 300'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),  '0') AS float64)) BETWEEN 300 AND 500 THEN '0300 - 500'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),
        '0') AS float64)) BETWEEN 500
  AND 800 THEN '0500 - 800'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),  '0') AS float64)) BETWEEN 800 AND 1000 THEN '0800 - 1000'
    WHEN (CAST(IfNULL(REGEXP_EXTRACT(calories, r"[0-9]+.[0-9]+"),
        '0') AS float64)) BETWEEN 1000
  AND 1500 THEN '1000 - 1500'
    ELSE '1500+'
  END AS calories_amount_bin,
  COUNT(*) AS count_of_recipes
FROM
  temp_recipes
CROSS JOIN
  UNNEST (nutrition) AS calories
WHERE
  calories LIKE 'Calories%'
  AND calories NOT LIKE 'Calories from%'
GROUP BY
  1
ORDER BY
  1 ASC