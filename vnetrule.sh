#Create Service principal
msg "Creating Service principal for VNET Rule"
passwd=$(az ad sp create-for-rbac --name virtualnetworkrule --query password -o tsv)
sleep 5
appid=$(az ad sp show --id http://virtualnetworkrule --query appId -o tsv)
tenantid=$(az ad sp show --id http://virtualnetworkrule --query appOwnerTenantId -o tsv)

#Get Subscription ID
sub=$(az account list --output table | awk 'FNR == 3 {print $4}')

#Generate access token
token=$(curl -X POST -d 'grant_type=client_credentials&client_id="'$appid'"&client_secret="'$passwd'"&resource=https%3A%2F%2Fmanagement.azure.com%2F' https://login.microsoftonline.com/$tenantid/oauth2/token | jq .access_token | sed 's/\"//g')

#Create VNET Rule using API
sleep 2
msg "Creating VNET Rule for SQL server"
curl -X PUT -H "Authorization: Bearer $token" -H "Content-Type: application/json" --data '{ "properties": { "ignoreMissingVnetServiceEndpoint": "false", "virtualNetworkSubnetId": "/subscriptions/'$sub'/resourceGroups/PhoenixCatalogStg/providers/Microsoft.Network/virtualNetworks/'$azvnet'/subnets/'$azsubnet'" }}' https://management.azure.com/subscriptions/$sub/resourceGroups/PhoenixCatalogStg/providers/Microsoft.Sql/servers/gecastgsqlsrv$label/virtualNetworkRules/sqlaccess$label?api-version=2015-05-01-preview
