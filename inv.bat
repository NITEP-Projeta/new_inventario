@echo off
setlocal

:: Configurações
set "STATUS=login"
set "API_URL=http://192.168.15.102:8000/inventario"

:: Informações básicas do ambiente
set "USER=%USERNAME%"
set "HOSTNAME=%COMPUTERNAME%"
set "DOMAIN=%USERDOMAIN%"

:: Chama PowerShell para coletar dados e enviar
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { " ^
    " $bios = Get-CimInstance -ClassName Win32_BIOS; " ^
    " $cs = Get-CimInstance -ClassName Win32_ComputerSystem; " ^
    " $prod = Get-CimInstance -ClassName Win32_ComputerSystemProduct; " ^
    " $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem; " ^
    " $net = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' } | Select-Object -First 1; " ^
    " $mac = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1; " ^
    " $obj = [PSCustomObject]@{ " ^
      "timestamp = (Get-Date).ToString('o'); " ^
      "user = '%USER%'; " ^
      "hostname = '%HOSTNAME%'; " ^
      "domain = '%DOMAIN%'; " ^
      "serial_number = $bios.SerialNumber; " ^
      "model = $cs.Model; " ^
      "manufacturer = $cs.Manufacturer; " ^
      "uuid = $prod.UUID; " ^
      "os = $osInfo.Caption + ' ' + $osInfo.Version; " ^
      "ip = if ($net) { $net.IPAddress } else { '' }; " ^
      "mac = if ($mac) { $mac.MacAddress } else { '' }; " ^
      "status = '%STATUS%'; " ^
      "location_hint = ''; " ^
    " }; " ^
    " Invoke-RestMethod -Method Post -Uri '%API_URL%' -ContentType 'application/json' -Body ($obj | ConvertTo-Json) | Out-Null; " ^
    " Write-Output 'POST OK'; " ^
  " } catch { Write-Output \"ERRO: $_\"; exit 1 }"

endlocal
