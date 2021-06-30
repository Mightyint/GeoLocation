class ProcessExec{
    [Hashtable]$ExecutionSettings
    [String]$ComputerList
    
    hidden [Object]$OrderedData = @()
    hidden [String]$ErrVar
    
    [Boolean]$Local = $true
    [Boolean]$Remote = $false

    ProcessExec([String]$Computers){
        $this.ComputerList = $Computers
    }
    
    Initialize([Hashtable]$props){
        $this.SetExecutionSettings()
        [Hashtable]$hashProperties = $props + $this.ExecutionSettings
        $this.OrderedData += New-Object psobject -Property ($hashProperties)
    }
    
    [Object]GetProcessinfo(){
        return ($this.OrderedData)
    }
    
    [Hashtable]GetExecutionSettings(){
        return ($this.ExecutionSettings)
    }

    [String] GetComputerList(){
        return ($this.ComputerList)
    }

    RemoteStart(){
        $this.Remote = $true
        $this.Local = $false
    }
    
    SetExecutionSettings(){
        if(($this.ComputerList -eq $null) -or ($this.ComputerList -eq ".")){
            $this.ExecutionSettings = @{
                Remote = $this.Remote
                Local = $this.Local
                Errors = $this.ErrVar = "N/a"
            } 
        }
        else{
            $this.RemoteStart()
            $this.ExecutionSettings = @{
                Remote = $this.Remote
                Local = $this.Local
                Errors = $this.ErrVar
            }
        }
    }
    
    SetProcessinfo(){
        $ProcessData = Get-Process | select Handles, 
        Id, 
        ProcessName, 
        'CPU'

        $NetData = Get-NetTCPConnection | select LocalPort, 
        LocalAddress,
        RemotePort,
        State,
        OwningProcess,
        AppliedSetting,
        RemoteAddress

        foreach($P in $ProcessData){
            foreach($N in $NetData){
                if($N.OwningProcess -eq $P.Id){
                    [hashtable]$properties = [Ordered] @{
                        "HostName" = hostname;
                        "ProcessName" = $P.ProcessName
                        "RemoteAddress" = $N.RemoteAddress
                        "LocalAddress" = $N.LocalAddress
                        "RemotePort" = $N.RemotePort
                        "OwningProcess" = "$($N.OwningProcess),$($P.Id) "
                        "State" = $N.State
                        "AppliedSetting" = $N.AppliedSetting
                        "CPU Usage" = $P."CPU"
                        "Handles" = $P.Handles
                    }
                    $this.SetExecutionSettings()
                    $this.Initialize($properties)
                }
            }
        }
    }
    
    SetRemoteinfo(){
        foreach($Computer in $this.ComputerList){
            try{
                $ProcessData = Get-Process -ComputerName $Computer | select Handles, 
                Id, 
                ProcessName, 
                'CPU',
                MachineName
        
                $NetData = Get-NetTCPConnection -ComputerName $Computer | select LocalPort, 
                LocalAddress,
                RemotePort,
                State,
                OwningProcess,
                AppliedSetting

                foreach($P in $ProcessData){
                    foreach($N in $NetData){
                        if($N.OwningProcess -eq $P.Id){
                            $properties = [ordered]@{
                                HostName = $P.MachineName
                                ProcessName = $P.ProcessName
                                RemoteAddress = $N.RemoteAddress
                                LocalAddress = $N.LocalAddress
                                RemotePort = $N.RemotePort
                                OwningProcess = "$($N.OwningProcess),$($P.Id)"
                                State = $N.State
                                AppliedSetting = $N.AppliedSetting
                                "CPU Usage" = $P."CPU"
                                Handles = $P.Handles
                            }
                            $this.Initialize($properties)

                        }
                    }
        
                }
            }
            catch{
                $this.ErrVar = $_.Exception
                $properties = [ordered]@{
                    HostName = ""
                    ProcessName = "N/a"
                    RemoteAddress = "N/a"
                    LocalAddress = "N/a"
                    RemotePort = "N/a"
                    OwningProcess = "N/a"
                    State = "N/a"
                    AppliedSetting = "N/a"
                    "CPU Usage" = "N/a"
                    Handles = "N/a"
                }
                $this.Initialize($properties)
            }
        }
    }
}
