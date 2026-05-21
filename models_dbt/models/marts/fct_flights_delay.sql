{{ config(
    materialized = 'table',
    cluster_by = ['flight_date', 'airport']
) }}

SELECT
    year,
    month,
    DATE_FROM_PARTS(year, month, 1) AS flight_date,
    airport,
    carrier_name,
    SUM(arr_flights) AS total_flights,
    SUM(arr_del15) AS delayed_flights,
    SUM(arr_delay) AS total_delay_minutes,
    SUM(carrier_delay) AS carrier_delay,
    SUM(weather_delay) AS weather_delay,
    SUM(nas_delay) AS nas_delay,
    SUM(late_aircraft_delay) AS late_aircraft_delay
FROM {{ ref('stg_flights') }}
GROUP BY 1,2,3,4,5