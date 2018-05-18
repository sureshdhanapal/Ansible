How to connect Ansible Control Machine (Linux) with Client (Windows)

Prerequisites:

Ansible (>= 2.3.0) installed linux machine with
Package: Python2-winrm (pip install pywinrm)a or later

Windows Machine with Powershell (>= 3.0)
Script to be downloaded: https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
      

Step 1: YML file on ACM Server

Create a file group_vars/windows.yml and define the below inventory variables:

# it is suggested that these be encrypted with ansible-vault:
# ansible-vault edit group_vars/windows.yml
ansible_user: Administrator
ansible_password: SecretPasswordGoesHere
ansible_port: 5986
ansible_connection: winrm
# The following is necessary for Python 2.7.9+ (or any older Python that has backported SSLContext, eg, Python 2.7.5 on RHEL7) when using default WinRM self-signed certificates:
ansible_winrm_server_cert_validation: ignore

Step 2:  Encrypt the files using ansible-vault 
FYI: http://docs.ansible.com/ansible/playbooks_vault.html

Step 3: Run the downloaded powershell script on Client Machine.

  i. Open command prompt -> Run as Administrator -> powershell.exe -File “/filepath/ConfigureRemotingForAnsible.ps1”
  ii. Open Powershell -> Run as Administrator 
Set-executionpolicy unrestricted
“/filepath/ConfigureRemotingForAnsible.ps1”


Note:
You need to prep your windows machine for PowerShell remote management, otherwise ansible won't be able to connect to it. For most features to work you will need at least PowerShell 3.0 installed and run the above script, which will not only enable WinRM, but also install some necessary certificates for the connection to work.


Step 4: Hosts file Modification

Modify ansible inventory file and add the Client IP with a group name .

Example:


Note: The name of the file in your group_vars folder (windows.yml) needs to agree with the group name in your inventory.



Step 5: Ping command

Once the above configurations done, We can able to connect to the Client machine. 













Play:

- hosts: windows
  tasks:

   - name: Download the putty package
 	win_get_url:
  	url: https://the.earth.li/~sgtatham/putty/0.70/w64/putty-64bit-0.70-installer.msi
  	dest: C:\Users\Administrator\Downloads\putty-64bit-0.70-installer.msi
  	force: no
   - name: Install putty
 	win_msi:
  	path: C:\Users\Administrator\Downloads\putty-64bit-0.70-installer.msi
  	wait: true
   - name: bat script to find the ip
  	win_shell: C:\ip.bat
  	register: data
	- debug: msg={{ data.stdout_lines }}
	- local_action: copy content={{ data.stdout_lines }} dest=/etc/ansible/playbooks/ip
	- name: Grep the IP from localhost file
  	shell: cat /etc/ansible/playbooks/ip | cut -c 3-15
  	delegate_to: localhost
  	register: ip
	- debug: msg={{ip.stdout}}
	- set_fact: snap={{ip.stdout}}
	- name: Create a file in Windows server with IP Address
  	win_file:
   	path: C:\{{snap}}.txt
   	state: touch
   - name: Shortcut for putty in C drive
 	win_shortcut:
  	src: C:\Program Files\PuTTY\pscp.exe
  	dest: C:\pscp.lnk
  	icon: C:\Program Files\PuTTY\pscp.exe,0
   - name: Copy ppk file to remote machine
 	win_copy:
  	src: /etc/ansible/windows/AWS_TCS.ppk
  	dest: C:\AWS_TCS.ppk
   - name: Check for latest Patches
 	win_shell: powershell C:\patch.ps1 > C:\{{snap}}.txt
   - name: Copy patch update details to local - filepath = /home/windows/updates.txt
 	win_shell: C:\pscp.lnk -i "C:\AWS_TCS.ppk" C:\{{snap}}.txt windows@172.31.48.37:/home/windows/{{snap}}.txt


Filename: Patch.ps1

$update = new-object -com Microsoft.update.Session
$searcher = $update.CreateUpdateSearcher()
$pending = $searcher.Search("IsInstalled=0")
foreach($entry in $pending.Updates)
{
	Write-host "Title: " $entry.Title
	Write-host "Downloaded? " $entry.IsDownloaded
	Write-host "Description: " $entry.Description
	foreach($category in $entry.Categories)
	{
    	Write-host "Category: " $category.Name
	}
	Write-host " "
}



Filename: ip.bat

@echo off
ipconfig | findstr /i "IPv4" > tmpfile
for /f "tokens=2-14" %%a in (tmpfile) do echo %%m 


