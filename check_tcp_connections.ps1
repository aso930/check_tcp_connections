


#Modify as you wish
$warning = 60000
$critical = 64000
$path = "./libexec/port_statistics/log"
$retention = (Get-Date).AddDays(-14)


#Do not modify
$tcp_con_total = 0
$exit_code = 0

$tcp_status = @{
    Bound = 0
    Closed = 0
    CloseWait = 0
    Closing = 0
    DeleteTCB = 0
    Established = 0
    FinWait1 = 0
    FinWait2 = 0
    LastAck = 0
    Listen = 0
    SynReceived = 0
    SynSent = 0
    TimeWait = 0
}


#Clean-up logs

if( Test-Path $path)
{
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
    }
    else
    {
        New-Item -ItemType directory -Path ./libexec/port_statistics/log
        }

#Save connections to file

Get-NetTCPConnection | Export-Csv -Append $path/$((Get-Date).ToString('yyyy-MM-dd'))-connections.csv

#Connections by tcp status
$connections = Get-NetTCPConnection | group state | sort name

foreach($connection in $connections)
{
    switch ($connection.Name)
    {
        "Bound" { $tcp_status.Set_Item("Bound",$connection.Count) }
        "Closed" {$tcp_status.Set_Item("Closed",$connection.Count) }
        "CloseWait" { $tcp_status.Set_Item("CloseWait",$connection.Count) }
        "Closing" { $tcp_status.Set_Item("Closing",$connection.Count) }
        "DeleteTCB" { $tcp_status.Set_Item("DeleteTCB",$connection.Count) }
        "Established" { $tcp_status.Set_Item("Established",$connection.Count) }
        "FinWait1" { $tcp_status.Set_Item("FinWait1",$connection.Count) }
        "FinWait2" { $tcp_status.Set_Item("FinWait2",$connection.Count) }
        "LastAck" { $tcp_status.Set_Item("LastAck",$connection.Count) }
        "Listen" { $tcp_status.Set_Item("Listen",$connection.Count) }
        "SynReceived" { $tcp_status.Set_Item("SynReceived",$connection.Count) }
        "SynSent" { $tcp_status.Set_Item("SynSent",$connection.Count) }
        "TimeWait" { $tcp_status.Set_Item("TimeWait",$connection.Count) }
        default {  }
    }
}

#Total number of connections

$tcp_connections = Get-NetTCPConnection
$tcp_con_no = $tcp_connections.Count
echo "Number of TCP connections is equal to $tcp_con_no` <BR> Number of TCP connections in CLOSE_WAIT is equal to $($tcp_status.Get_Item("CloseWait"))` | Bound=$($tcp_status.Get_Item("Bound")); Closed=$($tcp_status.Get_Item("Closed")); CloseWait=$($tcp_status.Get_Item("CloseWait")); Closing=$($tcp_status.Get_Item("Closing")); DeleteTCB=$($tcp_status.Get_Item("DeleteTCB")); Established=$($tcp_status.Get_Item("Established")); FinWait1=$($tcp_status.Get_Item("FinWait1")); FinWait2=$($tcp_status.Get_Item("FinWait2")); LastAck=$($tcp_status.Get_Item("LastAck")); Listen=$($tcp_status.Get_Item("Listen")); SynReceived=$($tcp_status.Get_Item("SynReceived")); SynSent=$($tcp_status.Get_Item("SynSent")); TimeWait=$($tcp_status.Get_Item("TimeWait"))"

#CloseWait and TimeWait trend




#Set exit code

if($tcp_con_total.Count -gt $critical)
{
    $exit_code=2
}
elseif ( $tcp_con_total.Count -gt $warning )
{
    $exit_code=1
}

exit $exit_code
