WITH height_values AS (SELECT
	operator,
	ROW_NUMBER() OVER (PARTITION BY operator),
	height,
	AVG(height) OVER (PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_height,
	STDDEV(height) OVER (PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS stddev_height,
	item_no
FROM manufacturing_parts
ORDER BY item_no
)

SELECT
	operator,
	row_number,
	height,
	avg_height,
	stddev_height,
	(avg_height + (3 * (stddev_height / SQRT(5)))) AS ucl,
	(avg_height - (3 * (stddev_height / SQRT(5)))) AS lcl,
	CASE WHEN
		height BETWEEN (avg_height - (3 * (stddev_height / SQRT(5)))) AND (avg_height + (3 * (stddev_height / SQRT(5)))) THEN 'False'
		ELSE 'True'
		END AS alert
FROM height_values
WHERE row_number >= 5;