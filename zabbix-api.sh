#!/bin/bash
source config.sh
cd "$(dirname "$0")"
apitoken=$(cat zabbix_api_token)


for t in ${triggerid[@]};
do

rm -rf create_ticket.txt
cp create_ticket.txt.bk create_ticket.txt

triggerstatus=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"trigger.get","id":1,"auth":"'$apitoken'", "params":{"triggerids": '$t', "output": "extend" }}'  $zabbixurl | jq '.' |grep value |cut -c 17)
trigername=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"event.get","id":1,"auth":"'$apitoken'", "params":{"objectids": '$t', "output": "extend"}}'  $zabbixurl | jq '.'  |grep name |head -n1 |cut -c15-)
eventtime=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"problem.get","id":1,"auth":"'$apitoken'", "params":{"output": "extend", "objectids": '$t' }}'  $zabbixurl | jq '.' |grep clock|head -n1| cut -c 17-26)
eventtimeinlinux=$(date -d @$eventtime)
###Need to change the event id after sometime
eventid=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"problem.get","id":1,"auth":"'$apitoken'", "params":{"output": "extend", "objectids": '$t' }}'  $zabbixurl | jq '.' |grep eventid|head -n1| cut -c 19-25)
echo $eventid:$t >> /tmp/zabbix_event_id
checkeventid=$(grep $eventid:$t /tmp/zabbix_event_id)

echo $trigername > output
#newitrigger=$(cat output)


sed -i  's/Test/'"$trigername"'/g' create_ticket.txt


echo $triggerstatus >> triggerid
##Create Ticket

if  [ "$triggerstatus" == 1 ]  &&  [ ! -z "$checkeventid" ]  ;
 then

ticketid=$(curl https://$zendomain.zendesk.com/api/v2/tickets.json -d @create_ticket.txt -H "Content-Type: application/json" -v -u $zenapi -s -X POST |cut -c 81-83)

echo $ticketid:$t >> /tmp/zabbix_zen_id
newticketid=$(cat /tmp/zabbix_zen_id |grep $ticketid| cut -c1-3 > newtickeid )

#echo new;

##update with else
elif [ "$triggerstatus" == 1 ] && [ ! -n "$checkeventid" ];
then
newticketid=$(cat /tmp/zabbix_zen_id |grep $ticketid:$t| cut -c1-3 |tail -n 1 )

#   echo new update
curl https://$zendomain.zendesk.com/api/v2/tickets/$newticketid.json -H "Content-Type: application/json" -d '{"ticket": {"status": "open", "comment": { "body": "Issue is still open." }}}' -v -u $zenapi -X PUT

###Close ticket
elif [ "$triggerstatus" == 0 ];
then
newticketid=$(cat /tmp/zabbix_zen_id |grep $ticketid:$t| cut -c1-3 |tail -n 1 )
curl https://$zendomain.zendesk.com/api/v2/tickets/$newticketid.json   -H "Content-Type: application/json" -d '{"ticket": {"status": "solved", "comment": { "body": "Issue solved." }}}' -v -u $zenapi -X PUT

  # sed -i  '/'$ticketid'/d' /tmp/zabbix_zen_id
  # sed -i  '/'$eventid'/d'  /tmp/zabbix_event_id


#echo close;

##Update ticket
else
echo lastupdate
fi

done
exit 0
