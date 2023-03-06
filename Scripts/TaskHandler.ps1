$tasks = New-Object Collections.Generic.List[String]
$tasksDone = [ordered]@{}
$tasksEnd = [ordered]@{}
$tasksName = [ordered]@{}
$allTasksDone = $false

function Start-Task() {
    [cmdletbinding()]
    Param(
        [String]
        $Name,
        [ScriptBlock]
        $Script,
        [ScriptBlock]
        $EndScript,
        [String]
        $ComplexName
    )       
    Start-Job -Name $Name -Scriptblock $Script
    $tasks.Add($Name)
    $tasksDone[$Name] = $false
    $tasksEnd[$Name] = $EndScript
    $tasksName[$Name] = $ComplexName
}

function Await-Tasks() {
    while($allTasksDone -eq $false) {
        $taskNotDone = $false

        foreach ($task in $tasks) {
            if ($tasksDone[$task] -eq $false) {
                $taskNotDone = $true
                $taskStatus = (Get-Job -Name $task) | Out-String
        
                if ($taskStatus.contains("Completed")) {
                    Invoke-Command -ScriptBlock $tasksEnd[$task]
                    $tasksDone[$task] = $true
                }
                elseif ($taskStatus.contains("Running")) {
                    $text = '[Running] ' + $tasksName[$task]
                    for ($i = 0; $i -lt $text.Length; $i++) {
                        $c = $text[$i]
            
                        Write-Host $c -NoNewline
                        Start-Sleep -Milliseconds 1
                    }
                    Write-Host ""
                }
                elseif ($taskStatus.contains("Blocked")) {
                    Write-Host '[Error] ' + $tasksName[$task] + ' Blocked !!!'
                    $tasksDone[$task] = $true
                }
                elseif ($taskStatus.contains("Failed")) {
                    Write-Host '[Error] '  + $tasksName[$task] + ' Failed !!!'
                    $tasksDone[$task] = $true
                }
            }
        }
        if ($taskNotDone -eq $false) {
            $allTasksDone = $true
        }
    }
}