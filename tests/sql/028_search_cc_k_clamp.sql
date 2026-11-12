-- search (CC): k is clamped to 1..50 with default 10
SELECT LEAST(GREATEST(COALESCE(NULL::bigint, 10), 1), 50) = 10
   AND LEAST(GREATEST(COALESCE(1000::bigint, 10), 1), 50) = 50
   AND LEAST(GREATEST(COALESCE(0::bigint, 10), 1), 50) = 1
   AND LEAST(GREATEST(COALESCE(-5::bigint, 10), 1), 50) = 1
   AND LEAST(GREATEST(COALESCE(7::bigint, 10), 1), 50) = 7 AS ok
