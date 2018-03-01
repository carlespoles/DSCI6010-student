-- Calculate % of different items obtained from SQL-1.sql file.

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
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'dairy-free')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_dairy_free,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'nut-free')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_nut_free,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'omnivore')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_omnivore,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'other')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_other,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'pescatarian')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_pescatarian,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'vegan')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_vegan,
  ROUND((
    SELECT
      COUNT(*) * 100
    FROM
      temp_recipes,
      UNNEST(diet_tags) AS dietary_tags
    WHERE
      dietary_tags = 'vegetarian')/ (
    SELECT
      COUNT(*)
    FROM
      temp_recipes),2) AS percent_recipes_vegetarian