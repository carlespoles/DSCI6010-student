
-- An example of extracting data (the amount field) using string functions.
-- One row of data looks like:

-- {"currency": "USD", "amount": "991.48", "unit": "dollar"}

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
  price_estimate,
  SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1) AS extracted_amount_part_a,
  SUBSTR(SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1), 0) AS extracted_amount_part_b,
  LENGTH(SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1)) AS total_length_string,
  LENGTH('", "unit": "dollar"}') AS rest_length_string,
  LENGTH(SUBSTR(SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1), 0))-LENGTH('", "unit": "dollar"}') AS length_string_of_interest,
  SUBSTR(SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1, LENGTH(price_estimate)), 0, LENGTH(SUBSTR(SUBSTR(price_estimate, LENGTH('{"currency": "USD", "amount": "')+1), 0))-LENGTH('", "unit": "dollar"}')) AS dollar_amount
FROM
  temp_recipes
ORDER BY
  extracted_amount_part_a DESC