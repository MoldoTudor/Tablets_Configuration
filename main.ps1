$setupPath = "C:\Users\moldo\AppData\Local\Android\Sdk\platform-tools\tablets_setup.ps1"
. $setupPath
.\adb start-server 


$Devices = .\adb devices | Select-String -Pattern "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+" | ForEach-Object { $_.ToString().Split("`t")[0] }

while ($true) {
    $Devices = .\adb devices | Select-String -Pattern "\tdevice$" | ForEach-Object { $_.ToString().Split("`t")[0] }
    $count = ($Devices | Measure-Object).Count
    
    if ($count -ge 2) {
        Write-Host "Found $count tablets. Starting process..." -ForegroundColor Green
        break
    }
    
    Write-Host "Only $count tablets found. Checking again in 2 seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
} 

 $Excel_Store = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

$Devices | ForEach-Object -Parallel {
    . ($using:setupPath)
    
    $ID = $_
    $adb = "C:\Users\moldo\AppData\Local\Android\Sdk\platform-tools\adb.exe"


    Write-Host "Starting on tablet: $ID" -ForegroundColor Blue
    
    $data = main -Serial $ID

   

   ($using:Excel_Store).Add($data)
    
    Write-Host "Finished on tablet: $ID" -ForegroundColor Cyan
  


} -ThrottleLimit 2

   if ($Excel_Store.Count -gt 0)
   {
	($Excel_Store.ToArray()) | Export-Csv -Path "C:\Exceluri_Tablete\Tablete_noi.csv" -NoTypeInformation -Append
   } 
	


.\adb kill-server