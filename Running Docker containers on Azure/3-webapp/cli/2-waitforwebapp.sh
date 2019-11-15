set -x
maxseconds=180
passedseconds=0
interval=3
while [[ "$(curl -s -o /dev/null -L -w "%{http_code}" https://$WEBAPP_NAME-staging.azurewebsites.net)" != "200" ]];  
  do
    passedseconds=$(( $passedseconds+$interval ))
    
    if [[ $passedseconds -ge $maxseconds ]]; then
      echo "ERROR: No healty website within the given timerange"  1>&2
      exit 1 # terminate and indicate error      
    fi
    sleep $interval; 
done