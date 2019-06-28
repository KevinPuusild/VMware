#NB! Palun lugeda ka kommentaare
#KUI LEIATE VEA MÕNES KOMMENTAARIS SIIS VABANDUSED JUBA ETTE
#Võtan kasutaja kellele ma teen DVPortGroupi muutujasse
#Alati saab muutujaid juurde kirjutada
$User = "eesnimi.perekonnanimi"
#Antud muutuja võib olla sama ülemisega, aga mõnel juhul tuleb juurde kirjutada DVportgroupile midagi, et eristada teda 
$User_Network = "eesnimi.perekonnanimi"
#Võtan Domeeni muutujasse
$Domain = "#Domain"
#Võtan DV_Switchi muutujasse
$Switch = "#DV_Switch"

#Genereerin kasutajale VLANI 41 JA 4096 Vahel ning kirjutan CSV faili, kui juba CSV fail on olemas siis võtan antud CSV failist ainult VLAN rea ning ekspordin -
#Selle .txt faili, kust saan kontrollida kas antud VLAN on juba kasutuses, kui on siis genereerib uue VLANi
       $random = Get-Random -Minimum 41 -Maximum 4096
        $data = Import-CSV -Path "C:\Users\install\Desktop\vmware\vork\VLAN_DATABASE.csv"  # CSV faili asukoht, kui ei ole siis skript teeb selle 
        $data | select -ExpandProperty "Vlan"  > "C:\Users\install\Desktop\vmware\vork\VLAN.TXT" #Kasutuses olevate VLANide loetelu .txt formaadis
 
        foreach($line1 in Get-Content "C:\Users\install\Desktop\vmware\vork\VLAN.TXT") { #Kasutuses olevate VLANide loetelu .txt formaadis
        if($line1 -eq $random){
        $random = $random1
        $random1 = Get-Random -Minimum 41 -Maximum 4096 
        }
    }
	
#Kontrollib kas antud nimeline DVPortGroup on juba olemas, tähele tuleb panna et kui ei ole siis viskab skripti käima pannes punase kirja, kui aga ei viska siis on antud -
#DVPortgroup juba olemas
if(-Not (Get-VDSwitch -Name $Switch | Get-VDPortgroup -Name $User_Network)) {
       Get-VDSwitch -Name $Switch | New-VDPortgroup -Name $User_Network -NumPorts 24 -VLanId $random

         }

#Küsin domeenist kasutaja eesnime ja perekonnanime kuna skript kirjutab kõik skripti andmed EESNIMI,PEREKONNANIMI,SAMACCOUTNAME,VLAN csv faili
 $eesnimi = Get-ADUser $User -Properties * | Select-Object -ExpandProperty givenname 
        $perekonnanimi = Get-ADUser $User -Properties * | Select-Object -ExpandProperty surname


       $csv = @(
    [pscustomobject]@{
        Eesnimi = $eesnimi
        Perekonnanimi = $perekonnanimi
        Kasutaja = $User
        Vlan = $random
    }| Export-csv -Path "C:\Users\install\Desktop\vmware\vork\VLAN_DATABASE.csv"  -Force -NoTypeInformation -Encoding utf8 -Append # CSV faili asukoht, kui ei ole siis teeb selle
   
)
#Võtan loetelu teistest VMwaret kasutavatest gruppide asukohta muutujasse
$Gruppid = "#Other_Groups"


#Samuti tekitame nüüd (loopi) ehk korduse, mis siis lisab õigused et iga üks ka ei näeks antud VDPortgroupi, vaid teatud kasutajad
 foreach($line in [System.IO.File]::ReadLines($Gruppid))
{
    $Kasutaja1 = Get-VIAccount -Domain $Domain -User -Id $User
    Get-VDPortgroup -Name $User_Network | New-VIPermission -Role (Get-VIRole -Name "Rights") -Principal $Kasutaja1 -Propagate:$true
    $viGroup1 = Get-VIAccount -Domain $Domain -Group $line
    Get-VDSwitch -Name $Switch | Get-VDPortgroup -Name $User_Network | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup1 -Propagate:$true


          
}

