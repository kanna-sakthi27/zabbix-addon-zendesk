#!/bin/bash
apitoken=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{ "params": { "user": "####", "password": "####" }, "jsonrpc": "2.0", "method": "user.login", "id": 0 }' 'http://###/zabbix/api_jsonrpc.php' | jq '.'|grep result |cut -c14-45 )

echo $apitoken >> zabbix_api_token
