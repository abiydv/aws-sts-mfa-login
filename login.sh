#!/bin/bash

token=${1}

# --- change as per your environment
home="/home/users/iam_user"
base="/tmp"
validity="129600"
account="123456890"
iam_user="iam_user"
# ---

aws sts get-session-token --duration-seconds ${validity} --serial-number arn:aws:iam::${aws_account_id}:mfa/${iam_user} --profile=default --token-code=${token} > ${base}/.resp.json

if [ $? -ne 0 ]; then
    exit $?
fi

access_key=$(jq -r .Credentials.AccessKeyId ${base}/.resp.json)
secret_key=$(jq -r .Credentials.SecretAccessKey ${base}/.resp.json)
session_token=$(jq -r .Credentials.SessionToken ${base}/.resp.json)

head -n 4 ${home}/.aws/credentials > ${base}/.new-creds
echo "[mfa]" >> ${base}/.new-creds
echo "aws_access_key_id=${access_key}" >> ${base}/.new-creds
echo "aws_secret_access_key=${secret_key}" >> ${base}/.new-creds
echo "aws_session_token=${session_token}" >> ${base}/.new-creds

cp head -n 5 ${home}/.aws/credentials head -n 5 ${home}/backups/aws-creds.$(date +%d%m%y-%H%M%S)
cp ${base}/.new-creds  ${home}/.aws/credentials

echo "export AWS_PROFILE=mfa"
