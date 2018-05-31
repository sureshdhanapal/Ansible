<powershell>
#requires -version 4.0
# Genpact-EU (Ireland) version
# This script detects platform and architecture, download and install matching Deep Security Agent 10 package
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
New-Item -path $env:LogPath -type directory
Start-Transcript -path "$env:LogPath\dsa_deploy.log" -append
echo "$(Get-Date -format T) - DSA download started"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
$baseUrl="https://dsm.genpact.com:443/"
if ( [intptr]::Size -eq 8 ) { 
   $sourceUrl=-join($baseurl, "software/agent/Windows/x86_64/") }
else {
   $sourceUrl=-join($baseurl, "software/agent/Windows/i386/") }
echo "$(Get-Date -format T) - Download Deep Security Agent Package" $sourceUrl
(New-Object System.Net.WebClient).DownloadFile($sourceUrl,  "$env:temp\agent.msi")
if ( (Get-Item "$env:temp\agent.msi").length -eq 0 ) {
echo "Failed to download the Deep Security Agent. Please check if the package is imported into the Deep Security Manager. "
 exit 1 }
echo "$(Get-Date -format T) - Downloaded File Size:" (Get-Item "$env:temp\agent.msi").length
echo "$(Get-Date -format T) - DSA install started"
echo "$(Get-Date -format T) - Installer Exit Code:" (Start-Process -FilePath msiexec -ArgumentList "/i $env:temp\agent.msi /qn ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru).ExitCode 
echo "$(Get-Date -format T) - DSA activation started"
Start-Sleep -s 50
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a dsm://hb.genpact.com:443/ "policyid:42"
Stop-Transcript
echo "$(Get-Date -format T) - DSA Deployment Finished"
</powershell> 

