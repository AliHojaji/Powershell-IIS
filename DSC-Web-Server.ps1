#--- Author : Ali Hojaji ---#

#--*-----------------*--#
#---> Configure IIS <---#
#--*-----------------*--#

#--> configuration
Configuration IISConfig {

    #resource
    WindowsFeature IIS {

    Ensure = "Present"
    Name = "Web-Server"

   }

}

#--> create the configuration (.mof)
IISConfig -ComputerName WEB-Test -OutputPath c:\nuggetlab

#--> push the configuration to WEB-NUG
Start-DscConfiguration -Path c:\nuggetlab -Wait -Verbose
