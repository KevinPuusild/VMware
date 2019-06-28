#NB! Palun lugege ka kommentaare!!!
#KUI LEIATE ET MÕNI KOMMENTAAR ON VALE SIIS VABANDAN ETTE ÄRA
#Võtan Kasutajate asukoha lokaalis muutujaks
$Kasutajad = "#Kasutajad"

#Võtan Template nime muutujaks
$templateName = '#template_name'
#Võtan ESXi nime või IP muutujaks, see on esialguseks, kui süsteemis on DRS lubatud siis vCenter hiljem ise tõstab ümber
$esxName = '#ESX_NIMi-VOI_IP'
#Võtan Cluster nime muutujaks
$clusterName = '#Cluster'
#Võtan Datastore muutujaks, kuhu skript peaks tegema masinad valmis
$dsName = '#VM_DATASTORE'
#Kasutab muutujaid
$template = Get-Template -Name $templateName
$ds = Get-Datastore -Name $dsName
$cluster = Get-Cluster -Name $clusterName
$esx = Get-VMHost -Name $esxName


#Tekitame niiöelda "loopi" ehk korduse mis meil teeb igale kasutajale antud templatest siis uue virtuaal masina
foreach($line in [System.IO.File]::ReadLines($Kasutajad))
{
#Võtan muutujaks kasutaja "ResourcePooli" 
$myResourcePool1 = Get-ResourcePool -Name $line
#Teeb masina
$vm = New-VM -Template $template -Name "#masinanimi" -ResourcePool $myResourcePool1 -Datastore $ds -DiskStorageFormat Thin | Set-VM -NumCpu 2 -MemoryGB 4 -Confirm:$false
#Tõstab masina kasutaja kausta samuti
$folder_vm = Get-Folder -Type VM -Name $line
Get-VM -Name "#masinanimi" | Move-VM -Destination $folder_vm

#Seda saab edasi arendada
}