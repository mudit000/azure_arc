Start-Transcript -Path C:\tmp\mssql_cleanup.log

# Deleting Azure Arc Data Controller namespace and it's resources (MSSQL incl.)
Start-Process PowerShell {for (0 -lt 1) {kubectl get pod -n $env:ARC_DC_NAME; sleep 5; clear }}
azdata arc sql mi delete --name $env:MSSQL_MI_NAME
azdata arc dc delete --name $env:ARC_DC_NAME --namespace $env:ARC_DC_NAME --force
kubectl delete ns $env:ARC_DC_NAME

az login --service-principal -u $env:SPN_CLIENT_ID -p $env:SPN_CLIENT_SECRET --tenant $env:SPN_TENANT_ID --output none
az resource delete -g $env:resourceGroup -n $env:ARC_DC_NAME --namespace "Microsoft.AzureArcData" --resource-type "dataControllers"

# Restoring State
Copy-Item -Path "C:\tmp\hosts_backup" -Destination "C:\Windows\System32\drivers\etc\hosts" -Recurse -Force -ErrorAction Continue
Copy-Item -Path "C:\tmp\settings_template_backup.json" -Destination "C:\tmp\settings_template.json" -Recurse -Force -ErrorAction Continue

Remove-Item "C:\Users\$env:adminUsername\AppData\Roaming\azuredatastudio\User\settings.json" -Force
Remove-Item "C:\tmp\hosts_backup" -Force
Remove-Item "C:\tmp\settings_template_backup.json" -Force

Stop-Transcript

Stop-Process -Name powershell -Force
