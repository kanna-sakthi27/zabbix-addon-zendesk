# zabbix-addon-zendesk
This code was writen to create/update/close tickets in zendesk on based on mentioned trigger IDs

## Requirments
1. Zabbix 4.0+, but should be working with lesser version also
1. jq installed on zabbix server
2. Listed down the triger IDs
3. Zendesk API token/ Zabbix creds

### Edit the below variables in the script
1. zenapi="useremail/token:apitoken"
2. triggerid=(### ### ### ###)
3. zabbixurl=http://IP_OF_ZABBIX/zabbix/api_jsonrpc.php
4. zendomain=
