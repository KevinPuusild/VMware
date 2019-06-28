#Võtan Vmware "Clusteri" muutujasse
$Cluster = "#Cluster"
$myCluster = Get-DatastoreCluster -Name $Cluster
#Otsin kõiki masinaid antud "Clusterist" mis töötavad
$allVms = Get-VM -Datastore $myCluster | where { $_.PowerState -eq “PoweredOn”}
#Panen need masinad kinni ning EI küsi üle et kas oled ikka nõus
Stop-VM -VM $allVms -Confirm:$false