#!/bin/bash

EMAIL= #please fill this field
AUTH_KEY= #this one too
PROXIED_TEMPFILE=proxied_records.json
LOGFILE=script.log

rm -rf $PROXIED_TEMPFILE
touch $PROXIED_TEMPFILE
zones_list=$(curl	-H "X-Auth-Email: $EMAIL" \
					-H "X-Auth-Key: $AUTH_KEY" \
					-H "Content-Type: application/json" \
					-X GET "https://api.cloudflare.com/client/v4/zones/" | jq '.')

echo "[" >> $PROXIED_TEMPFILE

i=0
zone_req=$(echo $zones_list | jq '.result['$i']')
while [ "$zone_req" != "null" ]; do
	zone_id=$(echo $zone_req | jq '.id')

	# Remove quotes from $zone_id variable
	temp="${zone_id%\"}"
	temp="${temp#\"}"
	zone_id=$temp

	recs_list=$(curl	-H "X-Auth-Email: $EMAIL" \
						-H "X-Auth-Key: $AUTH_KEY" \
						-H "Content-Type: application/json" \
						-X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" | jq '.')
	j=0
	rec_req=$(echo $recs_list | jq '.result['$j']')
	while [ "$rec_req" != "null" -a "$(echo $rec_req | jq '.proxied')" == "true" ]; do
		echo "$rec_req" >> $PROXIED_TEMPFILE
		echo "," >> $PROXIED_TEMPFILE
		# Check if next result exists for coma

		j=$((j+1))
		rec_req=$(echo $recs_list | jq '.result['$j']')
	done

	i=$((i+1))
	zone_req=$(echo $zones_list | jq '.result['$i']')
done

# Remove the latest coma
sed -i '$ d' $PROXIED_TEMPFILE

echo "]" >> $PROXIED_TEMPFILE

put_func () {
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$REC_ID" \
    -H "Content-Type:application/json" \
    -H "X-Auth-Key:$AUTH_KEY" \
    -H "X-Auth-Email:$EMAIL" \
    --data '{"type":'$REC_TYPE',"name":'$REC_NAME',"content":'$REC_CONTENT',"proxied":'$PROXIED'}' \
    | jq '.'
}

set_var_func () {
	i=0
	req=$(cat $PROXIED_TEMPFILE | jq '.['$i']')
	while [ "$req" != "null" ]; do
		temp=$(echo $req | jq '.zone_id')
		temp="${temp%\"}"
		temp="${temp#\"}"
		ZONE_ID=$temp
		temp=$(echo $req | jq '.id')
		temp="${temp%\"}"
        temp="${temp#\"}"
		REC_ID=$temp
		REC_NAME=$(echo $req | jq '.name')
		REC_CONTENT=$(echo $req | jq '.content')
		REC_TYPE=$(echo $req | jq '.type')
		put_func

		i=$((i+1))
		req=$(cat $PROXIED_TEMPFILE | jq '.['$i']')
	done
}

PROXIED=false
set_var_func

# Do you stuff here
# like renew Let's Encrypt certs, restart apache2 / nginx...
echo "All proxies have been disabled!"

PROXIED=true
set_var_func
echo "All proxies have been reenabled!"
