-- Example of de-duplicating data.

SELECT *
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id) as row
    FROM `firebase-wellio.recipes.imported_recipes`
  )
  WHERE row = 1