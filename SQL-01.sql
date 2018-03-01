-- Unnest a list of items in a row of BigQuery table.
-- One row of data looks like this (it's a list of ite,s):

-- vegetarian  
-- vegan  
-- pescatarian  
-- dairy-free   
-- omnivore   
-- other

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
  DISTINCT(dietary_tags)
FROM
  temp_recipes,
  UNNEST(diet_tags) AS dietary_tags
ORDER BY
  dietary_tags ASC