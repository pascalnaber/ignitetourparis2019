while [[ "$(curl -s -o /dev/null -L -w "%{http_code}" https://$WEBAPP_NAME-staging.azurewebsites.net)" != "200" ]]; 
  do printf '.'; 
  sleep 3; 
done