# Define a function called Get-MonitorInfo that takes a remote computer name as a parameter
function Get-MonitorInfo {
  param (
    # The name of the remote computer to query
    $ComputerName
  )

  # Define a function to decode byte arrays into strings. We will use this to translate the "UserFriendlyName" 
  function Use-Decode {
    If ($args[0] -is [System.Array]) {
      [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
      "Not Found"
    }
  }

  # Get the monitor information from the remote computer
  $MonitorInfo = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ComputerName $ComputerName

  # Loop through each monitor, grab the "UserFriendlyName", and display the model number
  foreach ($Monitor in $MonitorInfo) {
    $Model = Use-Decode $Monitor.UserFriendlyName
    Write-Output "Model: $Model"
  }
}
