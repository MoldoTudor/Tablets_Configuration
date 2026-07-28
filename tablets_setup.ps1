. .\Functions

 
function main
{
	param($Serial)
	$tableta = [K9]::new($Serial)
#	$tableta.Basic_Settings()
#	$tableta.Verificare_Basic_Settings()
#	$tableta.Apn()
#	$tableta.Selectare_Apn()
#	$tableta.Verificare_Apn() 
#	$tableta.Charging_Protection() 
#	$tableta.Check_Battery()
#	$tableta.Permissions_Viso() 
#	$tableta.Open_Viso()
#	$tableta.Xibo() 
	$data=Get_Data($Serial)
	return $data
}