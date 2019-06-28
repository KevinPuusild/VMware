#Võtan VDSwitchi Muutujasse
$VDSwitch = "VDSwitchi_nimi"
#Võtan asukoha kuhu tahan VLANi nimekirja exportida muutujasse
$Export_to = "#ASUKOHT/vlan.txt"

#Selekteerin kõik DvPortgroupid ja ekpordin nimekirja koos VLANidega välja
Get-VirtualSwitch -Name $VDSwitch | Get-VirtualPortGroup | `

Select Name, @{N="VLANId";E={$_.Extensiondata.Config.DefaultPortCOnfig.Vlan.VlanId}} > $Export_to