#!/bin/bash
for s in $( /usr/local/sbin/aws_auth.sh | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
    export $s;
done