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

                    'ServiceTag' = $response.assetheaderdata.ServiceTag;
                    'Model' = $response.productheaderdata.SystemDescription;
                    'StartDate' = [DateTime]$StartDate;
                    'EndDate' = [DateTime]$EndDate;
                    'ShipDate' = [DateTime]($response.assetheaderdata).ShipDate

                }

                $WarrantyObj = New-Object -TypeName psobject -Property $WarrantyProps
                $WarrantyObj.PSObject.TypeNames.Insert(0,'Dell.WarrantyInfo')
                Write-Output $WarrantyObj

            }

        } Catch {

            $error[0]

        }

    }

    End {}
    
}
#-----------------------------------------------------------------------------------------------------------------------
Function Get-DellWarranty {
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

        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String[]]$ServiceTag,

        [string]$API = 'API KEY',

        [Switch]$Dev
        
    )

    Begin {}

    Process {

        try {

            if ($PSBoundParameters.ContainsKey('Dev')) {

                $Server = "https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty/"

            } Else {

                $Server = "https://api.dell.com/support/assetinfo/v4/getassetwarranty/"

            }

            $tags = $ServiceTag -join ','
            $URI = "$Server" + "$Tags" + "?apikey=" + "$Api"
            Invoke-DellAPICall -URL $URI

        } Catch {

            $error[0]

        }

    }

    End {}


}