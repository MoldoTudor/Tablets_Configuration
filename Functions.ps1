function Tabs
{
	param($Number, $Serial)
	for($i=0;$i -lt $Number ;$i++)
	{
		.\adb -s $Serial shell input keyevent 20  # Down
	}
	.\adb -s $Serial shell input keyevent 66  # Enter
} 
function UP
{
	param($Number, $Serial)
	for($i=0;$i -lt $Number ;$i++)
	{
		.\adb -s $Serial shell input keyevent 19  # Down 
	}
	.\adb -s $Serial shell input keyevent 66  # Enter
}

function Press_OK
{	
	param($Serial)
	.\adb -s $Serial shell input keyevent 61  # This is TAB (moves focus to CANCEL)
	.\adb -s $Serial shell input keyevent 61  # This is TAB again (moves focus to OK)
	.\adb -s $Serial shell input keyevent 66  # This is ENTER (now it clicks the highlighted OK)
}

function Press_OK_short
{	
	param($Serial)
	.\adb -s $Serial shell input keyevent 61  # This is TAB (moves focus to Ok)
	.\adb -s $Serial shell input keyevent 66  # This is ENTER (now it clicks the highlighted OK)
}

class Data
{	
	[string] $SN
	[string] $IMEI
	[string] $ICCID

	Data([string] $SN, [string] $IMEI, [string] $ICCID)
	{
		$this.SN=$SN
		$this.IMEI=$IMEI
		$this.ICCID=$ICCID 
	}
	Data()
	{
		$this.SN=0
		$this.IMEI=0
		$this.ICCID=0 
	}
}
function Get_Data($Serie)
{
	$SN= (.\adb -s $Serie shell getprop ro.serialno).Trim()
	$raw_IMEI = .\adb -s $Serie shell "service call iphonesubinfo 1 s16 com.android.shell"
	$raw_IMEI = ($raw_IMEI | Select-String -Pattern "'(.+?)'" -AllMatches | ForEach-Object { $_.Matches | ForEach-Object { $_.Groups[1].Value }}) -join '' -replace '\.', ''
	$raw_ICCID= (.\adb -s $Serie shell getprop gsm.iccid).Trim()
	$ICCID="'$raw_ICCID"
	$IMEI="'$raw_IMEI"
	$data = [Data]::new($SN,$IMEI,$ICCID)
	return $data
}
 

class Tablets
{
	[string] $Serie
	Tablets([string]$Serie) 
	{
		$this.Serie = $Serie
	}
	[void] Collect_Data()
	{
	}
	[void] Basic_Settings()
	{
		$comenzi = "wm set-fix-to-user-rotation enabled; " +
			   "am broadcast -a com.mdm.smartrotate --ez enable_smart_rotate false; " +
			   "settings put system accelerometer_rotation 0; " +
			   "settings put system user_rotation 0; " +
			   "settings put system screen_brightness 4100; " +
			   "settings put secure emergency_gesture_enabled 0; " +
			   "settings put system screen_off_timeout 2147483647; " +
			   "settings put system screen_brightness_mode 0; " +
			   "cmd overlay enable com.android.internal.systemui.navbar.threebutton; " +
			   "pm disable-user --user 0 com.google.android.cellbroadcastreceiver; " +
			   "settings put secure spell_checker_enabled 0"

		.\adb -s $($this.Serie) shell "$comenzi"
		
		
	}
	[void] Verificare_Basic_Settings()
	{
		
		$comenzi = 'echo "$(settings get system accelerometer_rotation)"; ' +
			   'echo "$(settings get system user_rotation)"; ' +
			   'echo "$(settings get system screen_brightness)"; ' +
			   'echo "$(settings get secure emergency_gesture_enabled)"; ' +
			   'echo "$(settings get system screen_off_timeout)"; ' +
			   'echo "$(settings get system screen_brightness_mode)"; ' +
			   'echo "$(settings get secure spell_checker_enabled)"; ' +
			   'echo "$(cmd overlay dump | grep com.android.internal.systemui.navbar.threebutton)";  '+
			   'echo "$(pm list packages -d | grep com.google.android.cellbroadcastreceiver)"'

		$Rsp = .\adb -s $($this.Serie) shell "$comenzi"

		$Acelerometru=$Rsp[0].Trim()
		$Rotation=$Rsp[1].Trim()
		$Brightness=$Rsp[2].Trim()
		$Emergency=$Rsp[3].Trim()
		$Timeout=$Rsp[4].Trim()
		$Adaptive=$Rsp[5].Trim()
		$Spell=$Rsp[6].Trim()
		$Navigation=[bool]($Rsp -match "com.android.internal.systemui.navbar.threebutton:0")
		$Sos=[bool]($Rsp -match "com.android.internal.systemui.navbar.threebutton")

		if (($Acelerometru -eq 0) -and ($Rotation -eq 0) -and ($Brightness -eq 4100) -and ($Emergency -eq 0) -and ($Timeout -eq 2147483647) -and ($Adaptive -eq 0) -and ($Spell -eq 0) -and ($Navigation -eq 1) -and ($Sos -eq 1))
		{
			Write-Host "[OK] Setarile de baze ale tabletei $($this.Serie) au fost configurate cu succes" -ForegroundColor Green
		}
		else
		{
			Write-Host "[No] Setarile de baze ale tabletei $($this.Serie) nu au fost configurate corect $Acelerometru si $Rotation si $Brightness si $Emergency si $Timeout si $Adaptive si $Spell  $Sos si $Navigation" -ForegroundColor Red
		}
		
	
	}
		
	[void] Apn(){}
	[void] Charging_Protection()
	{
		$comenzi = "am start -a android.intent.action.POWER_USAGE_SUMMARY; " +
			   "sleep 3; " +
			   "input keyevent 61; " +
			   "input keyevent 61; " +
			   "input keyevent 61; " +
			   "input keyevent 66; " +
			   "sleep 2; " +
			   "input keyevent 66; " +
			   "sleep 2; " +
			   "input keyevent 61; " +
			   "input keyevent 61; " +
			   "input keyevent 66; " +
			   "sleep 2"

		.\adb -s $($this.Serie) shell "$comenzi"
	}
	[void] Permissions_Viso()
	{
		$comenzi = "appops set com.viso.mdm SYSTEM_ALERT_WINDOW allow; " +
			   "appops set com.viso.mdm GET_USAGE_STATS allow; " +
			   "appops set com.viso.mdm WRITE_SETTINGS allow; " +
			   "appops set com.viso.mdm REQUEST_INSTALL_PACKAGES allow; " +
			   "appops set com.viso.mdm PROJECT_MEDIA allow"

		.\adb -s $($this.Serie) shell "$comenzi"
	}
	[void] Open_Viso()
	{
		$comenzi = "am start -n 'com.viso.mdm/com.android.bthsrv.MainActivity'; " +
			   "sleep 2; " +
			   "input keyevent 61; " +
			   "input keyevent 20; " +
			   "input keyevent 66; " +
			   "input keyevent 4"

		.\adb -s $($this.Serie) shell "$comenzi"

	}
	[void] Xibo()
	{
		$Seria=(.\adb -s $($this.Serie) shell getprop ro.serialno).Trim()
		$comenzi = "sleep 30; " +
			   "monkey -p uk.org.xibo.client -c android.intent.category.LAUNCHER 1; " +
			   "sleep 5; " +
			   "settings put system user_rotation 0; " +
			   "settings put system accelerometer_rotation 0; " +
			   "sleep 5; " +
			   "input keyevent 20; " +
			   "input keyevent 20; " +
			   "input keyevent 20; " +
			   "input keyevent 66; " +
			   "input keyevent 66; " +
			   "sleep 2; " +
			   "input keyevent 19; " +
			   "input keyevent 122; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 112; " +
			   "input keyevent 67; " +
			   "input text $Seria; " +
			   "input keyevent 20; " +
			   "input keyevent 20; " +
			   'input text "**********"; ' +
			   "input keyevent 20; " +
			   'input text "***"; ' +
			   "input keyevent 20; " +
			   "input keyevent 66"
		
		.\adb -s $($this.Serie) install C:\Users\tudor.moldoveanu\Downloads\Xibo_for_Android_v3_R313.apk
		.\adb -s $($this.Serie) shell "$comenzi"
	}
	[void] AutoPower_On()
	{
	.\adb -s $($this.Serie) reboot bootloader
	Start-Sleep -Seconds 30 
	.\fastboot -s $($this.Serie) oem off-mode-charge 0
	.\fastboot -s $($this.Serie) reboot
	}
	[void] Check_Battery()
	{
		.\adb -s $($this.Serie) shell settings list global 
		.\adb -s $($this.Serie) shell settings list system 
		.\adb -s $($this.Serie) shell settings list secure
	}
	


}

class K9 : Tablets
{
	K9([string] $Serie) : base($Serie) {}
	[void] Apn()
	{
		$comenzi = "am start -a android.settings.NETWORK_OPERATOR_SETTINGS;" +
			   "sleep 4; " + 
			   "am start -a android.settings.NETWORK_OPERATOR_SETTINGS;" +
			   "sleep 4; " +
                           "input keyevent 61; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 20; " +
                           "input keyevent 66; " +
			   "sleep 4; " +
			   "input tap 690 90; " +
			   "sleep 4; " +
			   "input tap 200 300; " +												
			   "input text '*********'; " +
			   "input keyevent 61; " +						
			   "input keyevent 66; " +
			   "sleep 1; " +						
			   "input keyevent 66; " +												
			   "sleep 1; " +						
			   "input text '*********'; " +
			   "input keyevent 61; " +
			   "input keyevent 61; " +
			   "input keyevent 66; " +
			   "sleep 1; " +						
			   "input tap 750 50; "

			   
		.\adb -s $($this.Serie) shell "$comenzi"
	}
<#	[void] Selectare_Apn()
	{
		$text_apn="*******"
		.\adb -s $($this.Serie) shell uiautomator dump /sdcard/window_dump.xml | Out-Null
		.\adb -s $($this.Serie) pull /sdcard/window_dump.xml .\window_dump.xml | Out-Null
		$content = Get-Content .\window_dump.xml -Raw
		$escape = [regex]::Escape($text_apn)
		$where = "text=`"$escape`"[^>]*bounds=`"\[(\d+),(\d+)\]\[(\d+),(\d+)\]`""
		if($content -match $where)
		{
		$y1= [int]$Matches[2]
		$y2= [int]$Matches[4]
		$x1= [int]$Matches[1]
		$x2= [int]$Matches[3]
		$x = ($x1 + $x2)/2 
		$y = [int](($y1+$y2)/2)
		.\adb -s $($this.Serie) shell input tap $x $y
		Write-Host " x=$x si y=$y "
		}
		if (Test-Path .\window_dump.xml) { Remove-Item .\window_dump.xml }
	}
#>
		[void] Selectare_Apn()
	{
		$comenzi = "input keyevent 61; " +
			   "input keyevent 61; " +						
			   "input keyevent 61; " +
			   "input keyevent 61; " +
			   "input keyevent 20; " +						
			   "input keyevent 62"

			   
		.\adb -s $($this.Serie) shell "$comenzi"
	}
	[void] Verificare_Apn()
	{
	$apn= .\adb -s $($this.Serie) shell content query --uri content://telephony/carriers/preferapn | Select-String 'apn=' | ForEach-Object { ($_ -split 'apn=')[1] -split ',' | Select-Object -First 1 }
	if($apn -match "*********")
	{
		Write-Host " Tableta $($this.Serie) a preluat Apn corect" -ForegroundColor Green
	}
	else
	{
		Write-Host " Tableta $($this.Serie) a preluat Apn gresit , cel actual este $apn" -ForegroundColor Red
	}
	}
}