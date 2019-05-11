#!/bin/bash
cd "$(dirname "$0")"

EMAIL= #please fill this field or use arguments
AUTH_KEY= #this one too
PROXIED_TEMPFILE=proxied_records.json
LOGFILE=script.log
SILENT=false

noproxy_ops () {
	# Do your stuff here
	# like renew Let's Encrypt certs, restart apache2 / nginx...
	# Or entry arguments to launch script / operations
    # Remove this test if you want to include operations in this script
    if [ "$SILENT" = false ]; then
        echo "Please specify some operations to do with -op or -ops"
    fi
}

for i in "$@"
do
case $i in
    -akf=*|--authkey_file=*)
    AUTH_KEY_PATH="${i#*=}"
    AUTH_KEY=$(< $AUTHKEY_PATH)
    shift # past argument=value
    ;;
    -ak=*|--authkey=*)
    AUTH_KEY="${i#*=}"
    shift # past argument=value
    ;;
    -e=*|--email=*)
    EMAIL="${i#*=}"
    shift # past argument=value
    ;;
    -ops=*|--operations_script=*)
    OP_SCRIPT="${i#*=}"
    shift # past argument=value
    ;;
	-op=*|--operations=*)
	OPERATIONS="${i#*=}"
	shift # past argument=value
	;;
    -s|--silent)
    SILENT=true
    shift # past argument with no value
    ;;
    *)
    if [ "$SILENT" = false ] ; then
        echo "Warning: unrecognized option: ${i}"
    fi
    ;;
esac
done

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

		j=$((j+1))
		rec_req=$(echo $recs_list | jq '.result['$j']')
	done

	i=$((i+1))
	zone_req=$(echo $zones_list | jq '.result['$i']')
done

# Remove the latest coma
sed -i '$ d' $PROXIED_TEMPFILE

# Close the array for JSon format
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

if [ "$SILENT" = false ] ; then
	echo "All proxies have been disabled!"
fi

if [ -z "$OPERATIONS" -o -z "$OP_SCRIPT" ]; then
    noproxy_ops
else
    if [ -n "$OPERATIONS" ]; then
        eval $OPERATIONS
    fi
    if [ -n "$OP_SCRIPT" ]; then
        eval $OP_SCRIPT
    fi
fi

PROXIED=true
set_var_func

if [ "$SILENT" = false ] ; then
	echo "All proxies have been reenabled!"
fi
