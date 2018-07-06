az keyvault key create --vault-name genpactvault$labels --name diskencryptkey -p software
# Create an Azure Active Directory service principal for authenticating requests to Key Vault.
# Read in the service principal ID and password for use in later commands.
sp_password=$(az ad sp create-for-rbac -n diskencrypt --query password -o tsv)
sp_id=$(az ad sp show --id http://diskencrypt --query appId -o tsv)
# Grant permissions on the Key Vault to the AAD service principal.
az keyvault set-policy --name genpactvault$labels --spn $sp_id \
--key-permissions backup create decrypt encrypt get import list recover restore sign unwrapKey update verify wrapKey \
--secret-permissions backup get list recover restore set
# Encrypt the VM disks.
az vm encryption enable --resource-group PhoenixCatalogStg --name gecastgml$label --aad-client-id $sp_id --aad-client-secret $sp_password --disk-encryption-keyvault genpactvault$labels --key-encryption-key diskencryptkey --volume-type all
sleep 2
enc=$(az vm encryption show -n gecastgml$label -g PhoenixCatalogStg --query osDiskEncryptionSettings.enabled -o tsv)
encexpected=true 
                if [ "$enc" = "$encexpected" ]; then
                        msg "Encryption initiated, Please check the VM for progress"
                else 
                        error_exit "Encryption failed"
                        exit 1
