-- cgt_pronuncia: an unknown id is no row (a malformed uuid is a caller error, SQLSTATE 22P02)
SELECT (SELECT count(*) FROM cgt_sentenze WHERE id = CAST('00000000-0000-0000-0000-0000000000ee' AS uuid)) = 0 AS ok
