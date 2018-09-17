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

    Begin {

        if ($PSBoundParameters.ContainsKey('Dev')) {

            $Server = 'https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty/'
        
        } Else {
    
            $Server = 'https://api.dell.com/support/assetinfo/v4/getassetwarranty/'
    
        }

    }

    Process {

        try {
        
            $tags = $ServiceTag -join ','
            $URI = "$Server" + "$Tags" + '?apikey=' + "$Api"
            Invoke-DellAPICall -URL $URI

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