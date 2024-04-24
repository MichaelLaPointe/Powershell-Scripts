<#

.Synopsis    
    Powershell Profiles contain aliases, functions, and other enhancements
    to your Powershell Experience. Created for and by Modine IT Operations
    and Desktop Support Interns. 

.Description
    Learning how to use and manipulate this file will help you understand 
    Powershell better. The following script can be used to personalize
    your Powershell experience.

    DO NOT edit your profile unless you are comfortable doing it and understand
    all the code inside (Seriously, just don't. Powershell is a tool you need 
    to do your job and you don't want to make it unusable.) If you do edit your
    profile and make a mistake, you can delete the profile altogether and start 
    from scratch. Both your regular account and zero account each have their own
    Powershell profile (You can actually have up to FOUR for each account.)

.Notes
    Created By :  Michael LaPointe
                  BATT function created by Calvin Obermeyer
                  GETGROUP and USERADGROUPS functions by Andrew Chapman and Colin Kravig
    Created On :  June 2, 2021
    Updated    :  Constantly
    Keywords   :  Powershell, Profile, Function, Alias, Software Sheet, SCCM,
                    Password Generator, Blinking Text, Message, Active Directory,
                    Groups, Membership

################################################################################
#                                                                              #
#  How to Check if you already have a profile or not, and if not, create one!  #
#                                                                              #
################################################################################

        Check to see if you already have a Powershell profile 
           ** Test-Path $profile ** (if True, than you do. If false…)
	
        If you have a profile already, hooray… type this to edit your profile
            ise $profile    OR     notepad $profile
	
        Don't have a profile yet? Type this to create a new profile
            New-Item –Path $Profile –Type File –Force


          ################################################
          #                                              #
          #   List of things to do - proposed updates    #
          #                                              #
          ################################################

  * Find a way to get devices a user has logged on to without querying EVERY COMPUTER IN THE %#&$ DOMAIN! Query SCCM?
  * Break down functions in this profile as MODULES that can be imported, rather than one big script.
  * LONG TERM - Create a GUI with these tools using "Add-Type -AssemblyName System.Windows.Forms"
  * Incorporate FIND-USER into GET-USER because GET-USER requires a SamAccountName to be used.
  * Export Get-USER and GET-PC results into HTML files that can be attached to Help Desk tickets (may require a scripted "One Step" in Cherwell)
  * Create better error handling in GET-PC. It should just quit if the device is not found rather than throwing multiple errors. SilentlyContinue?
  * Change WRITE-HOST to WRITE-OUTPUT where applicable because Powershell Guru Don Jones has some pretty mean things to say about people who use WRITE-HOST
  * Figure out if we want COMMENT BASED HELP at the BEGINNING or END of functions and get consistent.
  * Start adding parameters, when applicable, to functions that are currently using READ-HOST.
  * Use COMPARE-OBJECT to compare lists of one user's AD groups to another. Make more robust


.Remarks
    "Comment Based Help" is fun. Look at me! I'm writing my own help file. 

.Link
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1
#>

#   Change error text from RED to GREEN. Because it doesn't represent a "problem",
#   it represents an "opportunity"! Plus, it's easier for me to read. So there's that.
#   If error messages annoy you, change both values to 'DarkMagenta'. But, errors won't be helpful.

$Host.PrivateData.ErrorForegroundColor = 'Green'
$Host.PrivateData.ErrorBackgroundColor = 'Black'

#   Enable Japanese Gameshow Hyperbole Mode for Title Bar
$Host.UI.RawUI.WindowTitle = "Super Extra Happy Fun Time Powershell Administrator Window"

####   Automatically set "Format-*" to AutoSize and Wrap

$PSDefaultParameterValues.Add('Format-*:AutoSize', $true)
$PSDefaultParameterValues.Add('Format-*:Wrap', $true)


################################
#                              #
#         FUNCTIONS            #
#                              #
################################

#    Want to learn how to write cool functions? Start with "Get-Help about_Functions", 
#    and when you realize that isn't too helpful, I recommend the book "Learn Powershell
#    Scripting in a Month of Lunches". Seriously.. it's a great book.
#
#
#    I've put functions in ALL CAPS so they are recognizable when you use tab complete.


Function FORMAT-BLINK {
    param([String]$Message, [int]$Delay, [int]$Count, [ConsoleColor[]]$Colors) 
    $startColor = [Console]::ForegroundColor
    $startLeft = [Console]::CursorLeft
    $startTop = [Console]::CursorTop
    $colorCount = $Colors.Length
    for ($i = 0; $i -lt $Count; $i++) {
        [Console]::CursorLeft = $startLeft
        [Console]::CursorTop = $startTop
        [Console]::ForegroundColor = $Colors[$($i % $colorCount)]
        [Console]::WriteLine($Message)
        Start-Sleep -Milliseconds $Delay
    }
    [Console]::ForegroundColor = $startColor

    <#
        .SYNOPSIS
            Format-Blink Function. This will cause output text to blink.
 
        .NOTES
            Name: Format-Blink (Joshua originally named this function "Blink-Message", but I changed it to adhere to naming standards.)
            Author: Joshua Honig on Microsoft Powershell Forum
            Version: 1.0
            DateCreated: 2020-Aug-5
 
        .LINK
            https://social.technet.microsoft.com/Forums/exchange/en-US/3e9585cf-bbed-4e8e-80ba-65fd0a3a71d5/flashing-text-in-powershell?forum=winserverpowershell
 
        .Description
            This function can be used for text that you want to call attention to. It will cause text to blink
            in multiple colors for a specified period. NOTE - The original author named this function "Blink-Message",
            but it has been changed as "Blink" is not an approved verb in the Powershell Environment. 

        .EXAMPLE
            Format-Blink "IT'S JOSHUA! HE'S STILL PLAYING THE GAME!" -delay 500 -count 100 -colors blue,red,red,yellow,red
        
        .EXAMPLE
            Format-Blink "Danger, Will Robinson!" -delay 100 -count 500 -colors blue,red
 
        .EXAMPLE
            Format-Blink -Message "Get your weight guessed right here! Only a buck! Actual live weight guessing. Take a chance and win some crap!" -Count 300 -Delay 100 -Colors Black,Blue,Cyan,DarkGray,DarkMagenta,DarkRed,Green,Red

        .PARAMETER Delay
            Specify the delay (in milliseconds) between blinks
 
        .PARAMETER Color
            Specify the colors the text should cycle through. 2-3 colors should be used, but more can be specified

        .PARAMETER Count
            Specify the number of color changes occur before script resumes
         #>
}



####   Define Message Function (Type "send-message" to send a message to a specific computer)

function SEND-MESSAGE {
    
    [CmdletBinding()]

    param(
        [Parameter(Mandatory)]
        [string[]]$ComputerName,
        [Parameter(Mandatory)]
        [string]$Message
    )
   
    msg  * /server:$ComputerName "$Message"

    <#
        .SYNOPSIS
            Send-Message Function. It sends a message. To a domain computer. That's it. You can define more than one $ComputerName 
        .NOTES
            Name: Send-Message
            Author: Michael LaPointe
            Version: 27.4.11
            Date Created: September 15, 2021
        .LINK
            https://youtu.be/RXJKdh1KZ0w
        .Description
            Use Send-Message to send a pop up message to a computer on the domain. It uses the CMD command "msg".
            This function can only send a message to a specific computer, not a specific user. Pop up window persists 
            for 2 minutes before disappearing. This function incorporates "Retro Encabulator" Technology to prevent
            side fumbling, so be sure to use "Get-Help Send-Messsage -online" for an easy-to-understand description.
        .EXAMPLE
            SEND-MESSAGE -ComputerName HAL9000 -Message "The 9000 series is the most reliable computer ever made. No 9000 computer has ever made a mistake or distorted information."
        .EXAMPLE
            Send-Message -ComputerName WOPR -Message "D.O.D pension files indicate current mailing address as: Dr. Robert Hume, a.k.a Stephen Falken, 5 Tall Cedar Road" 
        .EXAMPLE
            Send-Message -ComputerName THX1138 -Message "For more enjoyment and greater efficiency, consumption is being standardized. We are sorry.."
        .PARAMETER ComputerName
            System Name of the PC you want to send a message to. You can use more than one ComputerName 
        .PARAMETER Message
            Specify the message you want to send. 
         #>
}




####   Define SCCM Function (Type "sccm" to open an SCCM Window)
####   SCCM.RDP must be located on the user's Desktop. If it is not, 
####   point the path to the correct location.

function SCCM {
    powershell "cd 'C:\Users\$env:UserName\Desktop'; .\SCCM.rdp"
}





####   Define Weather Function  (Type "weather" to get a three day weather forecast)
####   "53403" is the area code for Modine - Racine. Just change the zip code in the URL 
####   to personalize if you want a different area. Looks best in full screen mode.
####   Fun Fact! The United States Postal Service says Utqiagvik, Alaska (zip code 99723)
####   is the US Post Office that experiences the coldest temperatures. 

function WEATHER {
    Write-Host "    Press Alt+Enter to view in full screen mode" -ForegroundColor Yellow -BackgroundColor Blue	
	(Invoke-WebRequest -UseBasicParsing http://wttr.in/53403?qF -UserAgent "curl").content
}




####   Define Get-Sheets Function (Type "open-sheets" to get a Software Sheet for a selected pc)
####   This is to get a list of all software installed on a machine.

function OPEN-SHEETS {
    Unblock-File -Path "C:\Temp\SoftwareSheet.Export.ps1" # We really don't store scripts in C:\Temp. 
    powershell "cd 'C:\Temp\'; .\SoftwareSheet.Export.ps1"
}



####   Define Find-User Function (Type "find-user" to type in the user's last and first name, and Powershell will find the 
####   corresponding SamAccountName.) Function uses the LIKE comparison so user doesn't have to type in name exactly.
####   Function created by Andrew Chapman, 1/25/22. Talk to Andrew C. to get a way-fancier GUI version of this function 
####   that can interact with Cherwell

function FIND-USER {
    Write-Host
    $NameFirst = Read-Host 'User First Name'
    $NameLast = Read-Host 'User Last Name'
    $NameLookup = "*$NameLast* *$NameFirst*"
    ##This doesn't work quite right## Get-ADUser -Filter Name -like $user* | Format-Table Name,SamAccountName -A
    Get-ADUser -F { name -like $NameLookup } | Format-Table Name, SamAccountName -A
}




####   Define Get-User Data Function (Type "Get-User" to get a prompt for ADuser information)

function GET-USER {
    Write-Host
    Write-Host
    $user = Read-Host "Please enter the User ID you want to query "
    Write-Host "-----------------------------------------------------------------------------" -ForegroundColor Yellow -BackgroundColor Blue
    Write-Host "-----------------------------------------------------------------------------" -ForegroundColor Yellow -BackgroundColor Blue
    Get-ADUser -Identity $user -Properties * | Select-Object Enabled, Title, CN, SamAccountName, City, State, Created, DistinguishedName, PrimaryGroup, EmailAddress, LastBadPasswordAttempt, PasswordExpired, PasswordLastSet, PasswordNeverExpires, LastLogonDate, LockedOut, logonCount, Manager, Modified, ObjectClass, ObjectCategory, telephoneNumber | format-list
    Write-Host
    Write-Host "Active Directory Membership" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host
    Start-Sleep -Seconds 2
    Get-ADUser -Identity $user -Properties memberof | Select-Object -ExpandProperty memberof | Sort-Object
    Write-Host
}


####   Define Get-CurrentWindowsVersion function. This function is called in the "GET-PC" function
####   This function requires assignment of the "$pc" variable. When used in the "GET-PC"
####   function, this will already be defined. When this function is used on it's own, 
####   you will need to assign "$pc" first.

function Get-CurrentWindowsVersion {
    Write-Host "Windows Version (As of 8-8-21, this should be 1909)" -ForegroundColor Cyan -BackgroundColor Black
    Invoke-Command -ScriptBlock { (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId } -ComputerName $pc
    Write-Output ""

    $IsVer1909 = Invoke-Command -ScriptBlock { (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId } -ComputerName $pc
    if ($IsVer1909 -ne '1909') {
        Format-Blink 'WINDOWS IS NOT VERSION 1909!! This PC needs to be upgraded!!' -delay 100 -count 50 -colors red, yellow, darkred, blue
        Write-Host "   Installed Version is $IsVer1909" -ForegroundColor Yellow
    }
    Else {
        Write-Host "Windows 10 v.1909 IS installed on $pc" -ForegroundColor White -BackgroundColor DarkGreen
    }
    Write-Output ""
}


####   Define Get-PCUptime function. This function is called in the "GET-PC" function
####   This function requires assignment of the "$pc" variable. when used in the "GET-PC"
####   function, this will already be defined. When this function is used on it's own, 
####   you will need to assign "$pc" first. 

function Get-PCUptime {
    #   Out-String).Trim() is used to get rid of the extraneous spacing that Format-Table and Format-List Like to do. 
    #   Opening parenthese must be added at the beginning of the expression.
    Write-Host "When was $pc Last Rebooted?" -BackgroundColor Black -ForegroundColor Cyan
    (Invoke-Command -ScriptBlock { (gcim Win32_OperatingSystem).LastBootUpTime } -ComputerName $pc | Select-Object DateTime | Format-List | Out-String).Trim()
    (Invoke-Command -ScriptBlock { (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime } -ComputerName $pc | Select-Object Days, Hours, Minutes | Format-Table | Out-String).Trim()
}


####   Define Get PC Data Function (Type "get-pc" to get a prompt for ADComputer and TPM information)
####   This function includes ADComputer Data as well as TPM information
####   This function REQUIRES the "Format-Blink" function be available. 
####   This function REQUIRES the "Get-RebootHistory" function be available.
####   This function REQUIRES the "Get-PCUptime" function be available.
####   This function REQUIRES the "Get-CurrentWindowsVersion" function be available.

function GET-PC {
    Write-Host
    Write-Host
    $pc = Read-Host "Please enter the PC# of the device you want to query " 
    Write-Host "-----------------------------------------------------------------------------------" -ForegroundColor Yellow -BackgroundColor Blue
    Write-Host "-----------------------------------------------------------------------------------" -ForegroundColor Yellow -BackgroundColor Blue
    Get-ADComputer -identity $pc -properties * | select-object Name, Created, DistinguishedName, DNSHostName, IPv4Address, LastLogonDate, LockedOut, logonCount, OperatingSystem, OperatingSystemVersion, primaryGroup, serialNumber | format-list
    Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc | Select-Object Name, Domain, TotalPhysicalMemory, Model, Manufacturer | Format-Table -AutoSize
    #    Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc
    Write-Output ""
    Write-Warning "If the following text is ERROR CODE, the device may be unavailable. Use Ctrl+C to cancel"
    ####       Need to create better ERROR handling here than just seeing ERROR CODE. 
    Write-Output ""
    Write-Output ""
    Get-CurrentWindowsVersion
    ####   Get TPM Information
    Write-Host "Get-TPM Information for $pc" -ForegroundColor Cyan -BackgroundColor Black
    Invoke-Command -ScriptBlock { get-tpm } -ComputerName $pc | select-object PSComputerName, TpmPresent, TpmReady, LockedOut | format-list
    Get-PCUptime
    Write-Output ""
    Write-Host "Who is currently logged on to $pc" -ForegroundColor Cyan -BackgroundColor Black #Need to add output if result is NULL
    (Get-WmiObject -Class win32_computersystem -ComputerName $pc).UserName
    Write-Output ""
    Write-Output ""
    ####   Most recent users on the PC based on the last write time of the user profile. 
    Write-Host "Most recent users to log on to PC"  -ForegroundColor Cyan -BackgroundColor Black
    Get-ChildItem "\\$pc\c$\Users" | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime -first 10
    Write-Output ""
    ####   The Following section commented out as it seems "Most Recent Users" gives the same info in a slightly different format.
    ####   Write-Host "User Profiles on $pc"
    ####   Returns user profiles but filters out system profiles using -ne
    ####   Get-WmiObject -ClassName Win32_userprofile -ComputerName $pc | Sort-Object firstusetime | Select-Object localpath | Where-Object {$_.localpath -ne 'C:\WINDOWS\ServiceProfiles\NetworkService' -and ( $_.localpath -ne 'C:\WINDOWS\ServiceProfiles\LocalService') -and ($_.localpath -ne 'C:\WINDOWS\system32\config\systemprofile')}
    Invoke-Command -ComputerName $pc { Get-PSDrive } | Format-Table
    Write-Host 
    Write-Host "Reboot History"  -ForegroundColor Cyan -BackgroundColor Black
    Get-RebootHistory -ComputerName $pc -DaysFromToday 90 -MaxEvents 10
}
####   END OF GET-PC FUNCTION



####   Defines Battery Information Function (type "get-batt" to get battery information from a remote computer)
####   Gets battery health information from a remote computer and exports to an HTML file
####   Script must be run as an administrator.
####   Original code © Calvin Obermeyer, August 2021

function GET-BATT {
    # Prompts user to input the remote computer number.
    $RHOST = Read-Host -Prompt 'Enter Computer Number'
    $LHOST = hostname

    if (Test-Connection -ComputerName $RHOST -Quiet) {
        if (Get-WmiObject Win32_Battery -Computername $RHOST) {
            #Informs user that the report is running.
            Write-Host -ForegroundColor Yellow "Running battery report on $RHOST."

            #Runs a battery report on the specified computer.
            Invoke-Command -ScriptBlock { powercfg /batteryreport /duration 14 } -ComputerName $RHOST

            # Opens the battery report file on the remote host after the report has finished.
            # Copies the battery report to the localhost.
            Copy-Item \\$RHOST\c$\Users\$env:UserName\Documents\battery-report.html -Destination C:\Users\$env:UserName\Documents\battery-report.html -PassThru

            #New Line
            Write-Host ""

            # Informs user that report copied to localhost
            Write-Host -ForegroundColor Green "Battery report copied to $LHOST."
            # Goest to path of where the battery-report.html file is saved
            Set-Location C:\Users\$env:UserName\Documents\
            #opens battery-report.html
            Write-Host
            Start-Sleep -Seconds 2
            Write-Host -ForegroundColor Green "Opening report in your default HTML viewer"
            .\battery-report.html
        }
        else {
            # Informs user that remote host is not a laptop
            Write-Host -ForegroundColor Red $RHOST "is not a Laptop."
        }
    }
    else {
        # Informs user that the remote host is not online
        Write-Host -ForegroundColor Red $RHOST "is not online."
    }
}



####   Defines GET-RANPASS function (Type "Get-RanPass" to generate a random password.)
####   This function will generate a 12 character password to be used TEMPORARILY!

#### SANITIZED version of this script only has 4 words in word array. PRODUCTION has 100.

Function GET-RANPASS {
<#
.Synopsis    
 	Get-Ranpass is a random password generator that can be used to supply
	TEMPORARY passwords for a user. It should not be used for passwords that
	are going to be used long-term. When the temporary password is given to 
	a user, you should immediately go to Active Directory and select "User 
	must change password at next logon".
.Description
	Get-Ranpass is a random password generator that can be used to supply
	TEMPORARY passwords for a user. It should not be used for passwords that
	are going to be used long-term. When the temporary password is given to 
	a user, you should immediately go to Active Directory and select "User 
	must change password at next logon". These passwords are designed to be
	more "Human Readable" than a purely random string of text, but with the 
	relatively few and unencrypted "seed" words, these are not very secure 
	passwords.

    For details on how to display any password in plaintext, even passwords 
    not generated here, be sure to use "Get-Help Get-Ranpass -online". Rick 
    has created a procedure for recovering passwords from any device.
.Notes
	Name :  Get-Ranpass
	Created By :  Michael LaPointe
	Created On :  October 12, 2021
.Example
	Get-Ranpass
.Inputs
	No inputs are supported
.Outputs
	The final password variable can be passed to the pipeline
.Link
	https://youtu.be/iik25wqIuFo
#>  
    $wordlist = @(
        'BluePen$'
        'Eff!cacy'
        'Emph@sis'
        'GreenB@y'
    )

    ####   Grab a random word from the array, then append a 4 digit number to it. 
    ####   "Minimum" is set to 2000 to avoid numbers that start with "0 or 1". 
    ####   These numbers could be confused with letters "O" or "L" and make the 
    ####   password difficult to read.

    $word = $wordlist | Get-Random
    $digit = Get-Random -Minimum 2000 -Maximum 9999

    $pass = $word + $digit

    Write-Host
    Write-Host "Your randomly generated password is `t $pass" # `t inserts a TAB character
    Write-Host
    Write-Warning "This is only a TEMPORARY password. Have user change password ASAP!"
    $pass | Set-Clipboard    # Save password to clipboard
    Write-Host
    Write-Host "Password has been copied to clipboard" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host

}
##    Original RANPASS Function. Process is adequate (and more secure), but new process is easier for enduser
##    Uncomment this function for a much more secure password
##        function RANPASS2
##          {
##        Write-Host
##        Add-Type -AssemblyName 'System.Web'
##        [System.Web.Security.Membership]::GeneratePassword(12,2)
##        Write-Host
##          }



####   Define GetGroup Function (Type "GET-GROUP" to see what users are members of a group)
####   OUT-GRIDVIEW is used to make the output more searchable
function GET-GROUP {
    Write-host
    $TheGroup = Read-Host 'What group do you wish to check membership for?'
    Get-ADGroupMember -Identity $TheGroup | Where-Object { $_.ObjectClass -eq "User" } |  Select-Object Name, SamAccountName | Out-GridView
    Write-Host
}



####   Define Get-UserADgroup Function (Type "Get-UserADgroup" to see AD Groups a user is a member of)
####   OUT-GRIDVIEW is used to make the output more searchable
Function GET-USERADGROUP {
    Write-Host
    $User = Read-Host 'What user do you want to check AD Membership for?'
    Get-ADUser -Identity $User -Properties memberof | Select-Object -ExpandProperty memberof | Out-GridView
    Write-Host
}



####   Define GetRebootHistory function. This function is called in the "GET-PC" function
####   This function requires assignment of the "$pc" variable. when used in the "GET-PC"
####   function, this will already be defined. When this function is used on it's own, 
####   you will need to assign "$pc" first.
Function GET-REBOOTHISTORY {
    <#
.SYNOPSIS
    This will output who initiated a reboot or shutdown event.
.NOTES
    Name: Get-RebootHistory
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2020-Aug-5
.LINK
    https://thesysadminchannel.com/get-reboot-history-using-powershell -
.EXAMPLE
    Get-RebootHistory -ComputerName Server01, Server02
.EXAMPLE
    Get-RebootHistory -DaysFromToday 30 -MaxEvents 1
.PARAMETER ComputerName
    Specify a computer name you would like to check.  The default is the local computer
.PARAMETER DaysFromToday
    Specify the amount of days in the past you would like to search for
.PARAMETER MaxEvents
    Specify the number of events you would like to search for (from newest to oldest)
#>
  
    [CmdletBinding()]  # Adding this line to the function changes it from a "regular" function to an "advanced" function
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]  $ComputerName = $env:COMPUTERNAME,
        [int]       $DaysFromToday = 7,
        [int]       $MaxEvents = 9999
    )
 
    BEGIN {}
 
    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                $Computer = $Computer.ToUpper()
                $EventList = Get-WinEvent -ComputerName $Computer -FilterHashtable @{
                    Logname   = 'system'
                    Id        = '1074', '6008'
                    StartTime = (Get-Date).AddDays(-$DaysFromToday)
                } -MaxEvents $MaxEvents -ErrorAction Stop
 
 
                foreach ($Event in $EventList) {
                    if ($Event.Id -eq 1074) {
                        [PSCustomObject]@{
                            TimeStamp    = $Event.TimeCreated
                            ComputerName = $Computer
                            UserName     = $Event.Properties.value[6]
                            ShutdownType = $Event.Properties.value[4]
                        }
                    }
 
                    if ($Event.Id -eq 6008) {
                        [PSCustomObject]@{
                            TimeStamp    = $Event.TimeCreated
                            ComputerName = $Computer
                            UserName     = $null
                            ShutdownType = 'unexpected shutdown'
                        }
                    }
 
                }
 
            }
            catch {
                Write-Error $_.Exception.Message
 
            }
        }
    }
 
    END {}
}


#Color Function Script
#Got this function from the Shane Young YouTube page, but he said he got it from somewhere else.
#This function just shows examples of the colors available in Powershell. These are all the NAMED 
#colors in Powershell. You can also use a HEX value for other colors to suit your needs.
function Show-Colors( ) {
    $colors = [Enum]::GetValues( [ConsoleColor] )
    $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
    foreach ( $color in $colors ) {
        Write-Host (" {0,2} {1,$max} " -f [int]$color, $color) -NoNewline
        Write-Host "$color" -Foreground $color
    }
}

function COMPARE-ADGROUPS{
<#
.Synopsis
   Compares the AD Memberships of two AD users
.DESCRIPTION
   User is prompted for two user names. The output shows if an entry is valid 
   for the first user (<=), second user (=>), or both users (==). You can remove
   the -IncludeEqual switch to rmove entries that appear in both lists. This
   makes the comparison a "This or That" function.
.EXAMPLE
   COMPARE-ADGROUPS
.EXAMPLE
   Compare-ADGroups
.EXAMPLE
   cOMPARE-adgROUPS
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Author  :  Michael LaPointe
   Date    :  March6, 2022
   Version :  1.0
.COMPONENT
   The component this cmdlet belongs to
.PARAMETER
   No parameters yet. The two user names will be added as parameters.
.LINK
   https://youtu.be/miC1VZ9UVCQ?t=38
   
#> 

$User1 = Read-Host "Who is the FIRST user you want to add to the comparison? (Please enter USERNAME)"
$User2 = Read-Host "Who is the SECOND user you want to add to the comparison? (Please enter USERNAME)"
$List1 = (Get-ADUser -Identity $User1 -Properties memberof | Select-Object -ExpandProperty memberof)
$List2 = (Get-ADUser -Identity $User2 -Properties memberof | Select-Object -ExpandProperty memberof)
Compare-Object -ReferenceObject $List1 -DifferenceObject $List2 | Out-GridView # Add -IncludeEqual to show ALL results
Write-Host
Write-Host "If SideIndicator points to the left (<=), the entry is ONLY in FIRST user's list." -ForegroundColor Yellow -BackgroundColor Black
Write-Host "If SideIndicator points to the right (=>), the entry is ONLY in SECOND user's list" -ForegroundColor Yellow -BackgroundColor Black
}

#################
#### Aliases ####
#################


Set-Alias -Name Remote -Value C:\Windows\System32\mstsc.exe
Set-Alias -Name WQLtest -Value C:\Windows\System32\wbem\wbemtest.exe
Set-Alias -Name Scan -Value Start-MpScan
Set-Alias -Name MESSAGE -Value send-message
Set-Alias -Name RANPASS -Value get-ranpass
Set-Alias -Name PC -Value get-pc
Set-Alias -Name USER -Value get-user
Set-Alias -Name BATT -Value get-batt
Set-Alias -Name SHEETS -Value open-sheets
Set-Alias -Name MENU -Value get-menu

#### Temporarily store Admin credentials as a secure string to be used when needed
$cred = Get-Credential

####   Starts transcript of the Powershell session and is saved to "OutputDirectory"
start-transcript -OutputDirectory "C:\Temp\Transcripts"

####   Sets prompt to C:

C:
CD\


function GET-MENU {
    ####   Clears screen and creates a short menu of available functions the user can invoke
    ####   Plus, it's kinda Green and Gold, sorta. 

    Clear-Host

    Write-Host
    Write-Host '    Get-PC            : Display information about a specific PC             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-User          : Query a User ID. Use "Find-User" to get username    ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Find-User         : Query AD to find the User ID for a user             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Send-Message      : Send a pop-up message to a PC                       ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-Batt          : Run a battery report on a laptop. HTML Display      ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    WEATHER           : Display a three day weather report                  ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-Sheets        : Bring up the Software Sheets dialog box             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    SCCM              : Bring up an SCCM Window                             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    RANPASS           : Generate a Random Password (NOT secure)             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    REMOTE            : Starts a Remote Desktop Connection                  ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-Group         : See what users are members of an AD group           ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-UserADGroup   : See the AD Groups a user is a member of             ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    Get-RebootHistory : Displays a history of reboots on a PC               ' -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host '    SHCM              : Precede any cmdlet with SHCM for a "GUI" version    ' -ForegroundColor Yellow -BackgroundColor DarkGreen
}
GET-MENU  # Clears the screen and displays the menu by calling the  GET-MENU  function.