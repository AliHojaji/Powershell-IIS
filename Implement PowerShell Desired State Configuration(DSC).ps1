#--- Author : Ali Hojaji ---#

#--*-----------------*--#
#---> Configure DSC <---#
#--*-----------------*--#

#--> create a DSC configuration to install IIS and support remote management
Configuration IISConfig

 #--> define input parameter
 Param(
     [string[]]$ComputerName = 'localhost'
     )

 #--> target machine(s) based on input param
 node $ComputerName {

      #--> configure the LCM
      LocalConfigurationManager {
          ConfigurationMode = "ApplyAndAutoCorrect"
          ConfigurationModeFrequencyMins = 15
          RefreshMode = "Push"
       }

      #--> install the IIS server role
      windowsFeature IIS {
          Ensure = "Present"
          Name = "Web-Server"
      }

      #--> install the IIS ermote management service
      WindowsFeature IISManagement {
          Name = 'web-Mgmt-service'
          Ensure = 'Present'
          Dependson = @('[windowsFeature]IIS')
      }

      #--> enable IIS remote management
      Registry RemoteManagement {
          key = 'HKLM:\SOFTWARE\Microsoft\webManagement\Server'
          ValueName = 'EnableRemoteManagement'
          ValueType = 'Dword'
          ValueData = '1'
          Dependson = @('[windowsFeature]IIs','[windowsFeature]IISManagement')
       }

       #--> configure remote management service
       Service WMSVC {
            Name = 'WMSVC'
            startupType = 'Automatic'
            State = 'Running'
            Dependson = '[Registry]RemoteManagement'
         }

    }

 #--> create the configuration (.mof)
 IISConfig -ComputerName WEB-NUG -Outputpath c:\nuggetlab

 #--> push the configuration to WEB-NUG
 Start-DscConfiguration -Path c:\nuggetlab -Wait -Verbose


 #--> enter powershell ermote session
 Enter-PSSession -ComputerName WEB-NUG

 #--> view installed features
 Get-WindowsFeature | Where-Object Installed -EQ True

 #--> view LCM propertise
 Get-DscLocalConfigurationManager

 #--> view configuration state
 Get-DscConfigurationStatus

 #--> test configuration drift
 Test-DscConfiguration

 #--> exit powershell remote session
 Exit-PSSession