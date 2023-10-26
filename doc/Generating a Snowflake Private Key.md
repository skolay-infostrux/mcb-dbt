# **Generating a Snowflake Private Key**
If you are configuring your connection to Snowflake for the first time, you might need to configure a private key pair.

If it doesn't exist, create a directory where we will store the encrypted RSA authentication keys (recommended folder `~/.ssh`)
```shell,
mkdir -p ~/.ssh
```

Optionally, once the keys are created (see methods below), you may want to<br>
Restrict access to the key files

```shell
chmod 400 ~/.ssh/snowflake_rsa_key.*
```


### Set Up Key Pair Authentication to Snowflake ###
### 1. Using `make keys`
Execute the following command in the root folder of the project:
```shell
make keys
```
This will execute a script which will prompt the user for a passphrase that will be used to encrypt the private key that is being generated. Once generated, the script will output the command needed to update your Snowflake user with this key.
```shell
Key pair generation complete!
Please update your Snowflake configuration with the public key:
```
```sql
ALTER USER <USER> SET RSA_PUBLIC_KEY_2='<PUBLIC_KEY>';
```
> NOTE: You may need to use role `ACCOUNTADMIN` above operation
> ```sql
> USE ROLE accountadmin;
> ```

### 2. Using bash script `generate_snowflake_keys.sh`
Execute the following command in the root folder of the project:
```
./scripts/generate_snowflake_keys.sh
```

#### Implementation of bash script `generate_snowflake_keys.sh`
```
#!/usr/bin/env bash

SNOWFLAKE_KEY_PATH="${HOME}/.ssh"
SNOWFLAKE_PRIVATE_KEY_PATH="${SNOWFLAKE_KEY_PATH}/snowflake_rsa_key.p8"
SNOWFLAKE_PUBLIC_KEY_PATH="${SNOWFLAKE_KEY_PATH}/snowflake_rsa_key.pub"
SNOWFLAKE_PASSPHRASE_PATH="${SNOWFLAKE_KEY_PATH}/snowflake_rsa_key.passphrase"

generate_snowflake_keys() {
	mkdir -p "${SNOWFLAKE_KEY_PATH}"
	read -s -r -p "Snowflake Private Key Passphrase: " passphrase
	echo "${passphrase}"
	openssl genrsa 2048 | \
	openssl pkcs8 -topk8 \
		-inform PEM \
		-passout pass:"${passphrase}" \
		-out "${SNOWFLAKE_PRIVATE_KEY_PATH}"
	openssl rsa -in "${SNOWFLAKE_PRIVATE_KEY_PATH}" -pubout \
		-passin pass:"${passphrase}" \
		-out "${SNOWFLAKE_PUBLIC_KEY_PATH}"
	printf '\n'

	public_key="$(head -n -1 < "${SNOWFLAKE_PUBLIC_KEY_PATH}" | tail -n +2 | tr -d '\n')"
	printf '%s\n\n' "Key pair generation complete!"
	printf '%s\n\n' "Please update your Snowflake configuration with the public key:"
	printf '%s\n\n' "ALTER USER <USER> SET RSA_PUBLIC_KEY_2='${public_key}';"


    echo PASSPHRASE: "${passphrase}"
	echo Public key file: "${SNOWFLAKE_PUBLIC_KEY_PATH}"
	echo Private key file: "${SNOWFLAKE_PRIVATE_KEY_PATH}"
}

if [ ! -f "${SNOWFLAKE_PRIVATE_KEY}" ]; then
	generate_snowflake_keys
fi
```
