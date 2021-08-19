#!/bin/bash

ACCESSKEY=
SECRETKEY=

function makeSignature() {
        nl=$'\\n'
        TIMESTAMP=$(echo $(date +%s000))
        SIG="$1"' '"$2"${nl}
        SIG+="$TIMESTAMP"${nl}
        SIG+="$ACCESSKEY"
        SIGNATURE=$(echo -n -e "$SIG"|iconv -t utf8 |openssl dgst -sha256 -hmac $SECRETKEY -binary|openssl enc -base64)
}

makeSignature GET /api/v2/channels

CHANNEL_LIST=$(curl -s -X GET \
 -H "Content-Type:application/json" \
 -H "x-ncp-apigw-timestamp:$TIMESTAMP" \
 -H "x-ncp-iam-access-key:$ACCESSKEY" \
 -H "x-ncp-apigw-signature-v2:$SIGNATURE" \
 -H "x-ncp-region_code:KR" \
 "https://livestation.apigw.ntruss.com/api/v2/channels" | grep -E -o '\"(ls-[0-9]{14}-[A-Za-z0-9]{5})\"' |sed 's/\"//g')

for channel in $CHANNEL_LIST
do
	echo "Deleting $channel...."

	makeSignature DELETE /api/v2/channels/$channel
	curl -s -X DELETE \
 		-H "Content-Type:application/json" \
 		-H "x-ncp-apigw-timestamp:$TIMESTAMP" \
 		-H "x-ncp-iam-access-key:$ACCESSKEY" \
 		-H "x-ncp-apigw-signature-v2:$SIGNATURE" \
 		-H "x-ncp-region_code:KR" \
 		"https://livestation.apigw.ntruss.com/api/v2/channels/$channel" -o /dev/null
	sleep 5
done
