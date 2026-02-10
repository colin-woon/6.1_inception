#!/bin/bash

# 1. Get the absolute path of the directory where this script lives
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# 2. Define the path to the .env and secrets relative to the script
ENV_FILE="$SCRIPT_DIR/../../.env"
SECRETS_DIR="$SCRIPT_DIR/../../../secrets"

# 3. Load the .env variables (specifically DOMAIN_NAME)
if [ -f "$ENV_FILE" ]; then
    # Use 'set -a' to automatically export all variables defined from here on
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# 4. Check if DOMAIN_NAME is actually set
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME is not set in .env"
    exit 1
fi

# 5. Create the secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# -nodes = headless, skips password prompt
# -newkey rsa:2048 = uses rsa encryption with strength of 2048 bits, unhackable by most modern computers but still fast
# -keyout = private key location
# -out = public key/cert location
# 6. Generate the cert ONLY if it doesn't already exist (Idempotency)
if [ ! -f "$SECRETS_DIR/inception.crt" ]; then
    echo "Generating SSL certificate for $DOMAIN_NAME..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SECRETS_DIR/inception.key" \
        -out "$SECRETS_DIR/inception.crt" \
        -subj "/C=MY/ST=KL/L=KL/O=42/OU=Inception/CN=${DOMAIN_NAME}"
    echo "SSL Certificate generated in $SECRETS_DIR"
else
    echo "SSL Certificate already exists. Skipping generation."
fi

# openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
# 	-keyout ../../secrets/inception.key \
# 	-out ../../secrets/inception.crt \
# 	-subj "/C=MY/ST=KL/L=KL/O=42/OU=Inception/CN=${DOMAIN_NAME}"