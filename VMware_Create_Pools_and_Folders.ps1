#PALUN LUGEDA KOMMENTAARE!!!!
#KUI KUSKIL ON MINGI VIGANE KOMMETAAR SIIS VABANDAN ETTE ÄRA :)
#Masinas peab olemas olema RSAT toolid ning olema samas domeenis kus on VMware
#Võtan Muutujasse Domeeni Gruppi nimi, Grupp peab olemas olema juba Active Directorys
$Domeen_Group = "#GROUP"
#Võtan muutujasse domeeni nime
$Domain = "#DOMAIN_NAME"
#VMwarel on enda käsk mille abiga saab määrata õigused, tavaline muutuja ei tööta.
$viGroup1 = Get-VIAccount -Domain $Domain -Group $Domeen_Group
#Võtan muutujasse õiguse nime kui ma tahan et kasutaja saaks asjale ligi, vCenteris peab olemas olema sama nimega "õigus"
$Role_Rights = "Rights"
#Võtan muutujasse õiguse kui ma tahan et keegi ligi ei saaks kuhugi, Vaikimisi on antud õigus juba olemas
$Role_No = "NoAccess"
#Võtame muutujasse "DatastoreCluster" nime
$Cluster = "#Clustername"

#Toome PS "sessioni" Active Directory mooduli.
Import-Module ActiveDirectory

#Võtan kasutajate asukoha muutujasse
$Kasutajad = "#Kasutajate_asukoht" # Asukoht Kasutajatele .txt fail, mis kasutajatele vaja teha on "Ressource Poole" ja Kaustasid
#Küsime domeenis kasutajate nimekirja
Get-ADGroupMember $Domeen_Group | Select-Object -ExpandProperty SamAccountName > "C:\Users\install\Desktop\ISP218.txt"

#Võtame gruppide listi asukoha muutujasse 
$Gruppid = "#Gruppide_asukoht"


#Teeme uue ülemise "RessourcePooli", kuhu alla hakkame tegema kasutajatele "RessourcePoole"
New-ResourcePool -Location $Cluster -Name $Domeen_Group -ErrorAction SilentlyContinue

#Võtame muutujasse selle "RessourcePooli" mille me just tegime
$resourcepool1 = Get-ResourcePool -Location $Cluster -Name $Domeen_Group
 
#Teeme uue ülemise kausta, kuhu alla hakkame tegema kasutajatele kaustasid
New-Folder -Name $Domeen_Group -Location VM

#Tekitame niiöelda "loopi" ehk korduse mis teeb meile igale kasutajale enda kausta ja "RessourcePooli"
 foreach($line in [System.IO.File]::ReadLines($Kasutajad))
{
	#Võtame muutujasse iga kasutaja eraldi
    $viuser = Get-VIAccount -Domain $Domain -User -id $line
	#Teeme $viuserile kausta
    Get-Folder -Type VM -Name $Domeen_Group | New-Folder $line
	#Teeme $viuserile "RessourcePooli"
    New-ResourcePool -Location $resourcepool1 -Name $line  

	#Kontroll õiguste jaoks, kuna testimisel tekkis olukord kus kasutaja sai õiguse sellele "RessourcePoolile" millele ta pole tohtinud
     If ($line -eq $line) {
	#Määrame õiguse kaustale, et iga kasutaja saaks just enda kasutale ligi mitte teiste omadele
    Get-Folder -Name $line -Location VM | New-VIPermission -Role (Get-VIRole -Name $Role_Rights) -Principal $viuser -Propagate:$false
	#Määrame õiguse "RessourcePoolile", et iga kasutaja saaks just enda "RessourcePoolile" ligi mitte teiste omadele
    Get-ResourcePool -Name $line | New-VIPermission -Role (Get-VIRole -Name $Role_Rights) -Principal $viuser -Propagate:$true

    }
     
	 
#Tekitame niiöelda "loopi" ehk korduse mis seadistab kohe kaustasid tehes niimoodi, et teised gruppid kes VMwaret ka kasutavad ei saaks nendel ligi
 foreach($line1 in [System.IO.File]::ReadLines($Gruppid))
{
	#Võtame iga gruppi eraldi muutujasse ja määrame õigused
    $viGroup2 = Get-VIAccount -Domain $Domain -Group $line1
    Get-Folder -Type VM -Name $line | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup2 -Propagate:$false
    Get-ResourcePool -Name $line | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup2 -Propagate:$true
    Get-Folder -Type VM -Name $Domeen_Group | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup2 -Propagate:$false
	
	#Määrame et teised gruppid ei saaks ligi kõige ülemisele "RessourcePoolile"
	
	
	#Siia tuleks tekitada kontroll juurde, kuna kui antud grupp millele teen "RessourcePoole" ja kaustasid on #GROUPS loendis siis tema ka ei saa ligi.
    Get-Folder -Type VM -Name $Domeen_Group | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup2 -Propagate:$false
    Get-ResourcePool -Name $Domeen_Group | New-VIPermission -Role (Get-VIRole -Name "NoAccess") -Principal $viGroup2 -Propagate:$true
    }
    

          
}
        


