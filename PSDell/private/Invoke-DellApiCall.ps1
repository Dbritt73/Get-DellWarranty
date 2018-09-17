Function Invoke-DellAPICall {
 <#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    Param (

        [URI]$URL

    )

    Begin {}

    Process {

        Try {

            $WarrantyInfo = Invoke-RestMethod -Uri $URL -Method 'GET' -ContentType 'Application/XML'

            foreach ($response in $WarrantyInfo.AssetWarrantyDTO.AssetWarrantyResponse.AssetWarrantyResponse) {

                $ObjFilter = $response.AssetEntitlementData.AssetEntitlement  | Where-Object {($_.ServiceLevelDescription -NE 'Dell Digitial Delivery') -and ($_.Entitlementtype -eq 'Initial') -or ($_.Entitlementtype -eq 'EXTENDED')}
                
                if (($ObjFilter).Count -gt 1) {

                    if ($ObjFilter[0].EndDate -gt $ObjFilter[1].EndDate) {
                
                        $StartDate = $ObjFilter[1].StartDate
                        $Enddate = $ObjFilter[0].EndDate
                
                    } Else {

                        $StartDate = $ObjFilter[0].StartDate
                        $EndDate = $ObjFilter[1].EndDate
                
                    }

                } Else {

                    $StartDate = ($ObjFilter).StartDate
                    $EndDate = ($ObjFilter).EndDate
                    
                }

                $WarrantyProps = [Ordered]@{

                    'ServiceTag' = $response.assetheaderdata.ServiceTag

                    'Model' = $response.productheaderdata.SystemDescription

                    'StartDate' = [DateTime]$StartDate

                    'EndDate' = [DateTime]$EndDate

                    'ShipDate' = [DateTime]($response.assetheaderdata).ShipDate

                }

                $WarrantyObj = New-Object -TypeName psobject -Property $WarrantyProps
                $WarrantyObj.PSObject.TypeNames.Insert(0,'Dell.WarrantyInfo')
                Write-Output -InputObject $WarrantyObj

            }

        } Catch {
        
            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve information about runtime error
            $info = [PSCustomObject]@{
            
              Exception = $e.Exception.Message
              Reason    = $e.CategoryInfo.Reason
              Target    = $e.CategoryInfo.TargetName
              Script    = $e.InvocationInfo.ScriptName
              Line      = $e.InvocationInfo.ScriptLineNumber
              Column    = $e.InvocationInfo.OffsetInLine
              
            }
            
            # output information. Post-process collected info, and log info (optional)
            $info
            
        }

    }

    End {}
    
}