SET block_encryption_mode = 'aes-256-cbc';
SET @key_str = SHA2('My secret passphrase',512);
SET @init_vector = RANDOM_BYTES(16);
SET @crypt_str = AES_ENCRYPT('text',@key_str,@init_vector);
SELECT CAST(AES_DECRYPT(@crypt_str,@key_str,@init_vector) AS CHAR);
