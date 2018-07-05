label=$(date +%Y%m%d)


passwd=$(az ad sp create-for-rbac --name suresh --query password -o tsv)
echo $passwd
sleep 5
appid=$(az ad sp show --id http://suresh --query appId -o tsv)
echo $appid
tenantid=$(az ad sp show --id http://suresh --query appOwnerTenantId -o tsv)
echo $tenantid

#Get Subscription ID

sub=$(az account list --output table | awk 'FNR == 3 {print $4}')

#Generate access token
token=$(curl -X POST -d 'grant_type=client_credentials&client_id="'$appid'"&client_secret="'$passwd'"&resource=https%3A%2F%2Fmanagement.azure.com%2F' https://login.microsoftonline.com/$tenantid/oauth2/token | jq .access_token | sed 's/\"//g')

sleep 2
#Create VNET Rule

curl -X PUT -H "Authorization: Bearer $token" -H "Content-Type: application/json" --data '{ "properties": { "ignoreMissingVnetServiceEndpoint": false, "virtualNetworkSubnetId": "/subscriptions/'$sub'/resourceGroups/geeks_rg/providers/Microsoft.Network/virtualNetworks/Dtlminjar/subnets/DtlminjarSubnet" }}' https://management.azure.com/subscriptions/$sub/resourceGroups/geeks_rg/providers/Microsoft.Sql/servers/tdegenpacttest/virtualNetworkRules/sqlaccess$label?api-version=2015-05-01-preview
