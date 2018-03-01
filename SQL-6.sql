-- Similar to SQL-5.sql but now the data has this structure (1 row of data):

-- {"name": "Alcohol, ethyl", "nutrient_id": "221", "unit": "g", "agg_value": 0.0}	 
-- {"name": "Caffeine", "nutrient_id": "262", "unit": "mg", "agg_value": 0.0}	 
-- {"name": "Calcium, Ca", "nutrient_id": "301", "unit": "mg", "agg_value": 1313.3905300353488}	 
-- {"name": "Carbohydrate, by difference", "nutrient_id": "205", "unit": "g", "agg_value": 162.99052465576816}	 
-- {"name": "Cholesterol", "nutrient_id": "601", "unit": "mg", "agg_value": 375.9498823787561}	 
-- {"name": "Energy", "nutrient_id": "208", "unit": "kcal", "agg_value": 2333.1553278007873}	 
-- {"name": "Fatty acids, total monounsaturated", "nutrient_id": "645", "unit": "g", "agg_value": 45.812315539385196}	 
-- {"name": "Fatty acids, total polyunsaturated", "nutrient_id": "646", "unit": "g", "agg_value": 23.205340564004327}	 
-- {"name": "Fatty acids, total saturated", "nutrient_id": "606", "unit": "g", "agg_value": 49.405855655327926}	 
-- {"name": "Fatty acids, total trans", "nutrient_id": "605", "unit": "g", "agg_value": 0.03039770861878195}	 
-- {"name": "Fiber, total dietary", "nutrient_id": "291", "unit": "g", "agg_value": 30.928357548404282}	 
-- {"name": "Iron, Fe", "nutrient_id": "303", "unit": "mg", "agg_value": 14.117875369935824}	 
-- {"name": "Magnesium, Mg", "nutrient_id": "304", "unit": "mg", "agg_value": 323.6146339264634}	 
-- {"name": "Potassium, K", "nutrient_id": "306", "unit": "mg", "agg_value": 4182.024917283204}	 
-- {"name": "Protein", "nutrient_id": "203", "unit": "g", "agg_value": 134.36223258379204}	 
-- {"name": "Sodium, Na", "nutrient_id": "307", "unit": "mg", "agg_value": 3643.3221832455997}	 
-- {"name": "Sugars, total", "nutrient_id": "269", "unit": "g", "agg_value": 27.08103267541787}	 
-- {"name": "Total lipid (fat)", "nutrient_id": "204", "unit": "g", "agg_value": 133.7551269233669}	 
-- {"name": "Vitamin A, IU", "nutrient_id": "318", "unit": "IU", "agg_value": 49854.13482607046}	 
-- {"name": "Vitamin C, total absorbic acid", "nutrient_id": "401", "unit": "mg", "agg_value": 415.64417814608424}	 
-- {"name": "Vitamin E (alpha-tocopherol)", "nutrient_id": "323", "unit": "mg", "agg_value": 12.62523061622084}	 


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
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) = 0 THEN '0'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 0
  AND 50 THEN '0 - 50'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 50 AND 100 THEN '0050 - 100'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 100
  AND 300 THEN '0100 - 300'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 300 AND 500 THEN '0300 - 500'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 500
  AND 800 THEN '0500 - 800'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 800 AND 1000 THEN '0800 - 1000'
    WHEN CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(calories, r'agg_value": [0-9]+.[0-9]+'), r'[0-9]+.[0-9]+') AS float64) BETWEEN 1000
  AND 1500 THEN '1000 - 1500'
    ELSE '1500+'
  END AS calories_preparation_bin,
  COUNT(*) AS count_of_recipes,
  LOG10(COUNT(*)) AS log10_count_of_recipes
FROM
  temp_recipes
CROSS JOIN
  UNNEST (derived_nutrition) AS calories
WHERE
  calories LIKE '%"unit": "kcal"%'
GROUP BY
  1
ORDER BY
  1