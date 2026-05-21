{{ config(
    materialized = 'table'
) }}

WITH base AS (
    SELECT *
    FROM {{ ref('fct_flights_delay') }}
),

totals AS (
    SELECT SUM(total_delay_minutes) AS total_delay FROM base
),

dim_delay_causes AS (

    SELECT 
        'Carrier' AS delay_type,
        SUM(carrier_delay) AS delay_minutes
    FROM base

    UNION ALL

    SELECT 'Weather', SUM(weather_delay) FROM base
    UNION ALL
    SELECT 'NAS', SUM(nas_delay) FROM base
    UNION ALL
    SELECT 'Late Aircraft', SUM(late_aircraft_delay) FROM base
)

SELECT 
    d.*,
    d.delay_minutes / t.total_delay AS pct_of_total
FROM dim_delay_causes d
CROSS JOIN totals t