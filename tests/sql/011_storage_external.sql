-- the original (non anonymized) text is kept out of line and uncompressed
SELECT (SELECT attstorage = 'e' FROM pg_attribute WHERE attrelid = 'cassazione_sentenze'::regclass AND attname = 'text_raw_original')
   AND (SELECT attstorage = 'e' FROM pg_attribute WHERE attrelid = 'cgt_sentenze'::regclass AND attname = 'text_raw_original') AS ok
