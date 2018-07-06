az keyvault create -n genpactvault$labels -g PhoenixCatalogStg -l eastus --enabled-for-disk-encryption True
az resource update --id $(az keyvault show --name genpactvault$labels -o tsv | awk '{print $1}') --set properties.enableSoftDelete=true
