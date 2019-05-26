#========================#
#region HELPER FUNCTIONS #
#========================#
function Add-Module {
   
    param(
        [string] $modulePath,
        [string] $moduleName,
        [string] $sourcePath
    )

    # Create Module root folder
    New-Item "$modulePath" -ItemType Directory -ErrorAction SilentlyContinue

    # Generate module content folders
    $folders = @('Pipeline', 'Test', 'Public', 'Private', 'Docs')
    $folders | ForEach-Object { New-Item "$modulePath\$_" -ItemType Directory -ErrorAction SilentlyContinue }

    # Create module file
    New-Item "$modulePath\DemoModule.psm1" -ItemType file -ErrorAction SilentlyContinue
    # Generate Manifest File
    $manifestData = @{
        Path          = "$modulePath\DemoModule.psd1"
        ModuleVersion = New-Object System.Version("0.1.0")
        Author        = "Alexander Sehr"
        RootModule    = "$modulename.psm1"
        CompanyName   = 'Microsoft'
        Description   = "Demo Module to introduce private artifact repositories"
        DefaultCommandPrefix = "$modulename"
    }
    New-ModuleManifest @manifestData -ErrorAction SilentlyContinue

    # Copy files
    Copy-Item -Path "$sourcePath\Pipeline\*" -Destination "$modulePath\Pipeline\" -Recurse
    Copy-Item -Path "$sourcePath\DemoModule.psm1" -Destination "$modulePath\"
    Copy-Item -Path "$sourcePath\FunctionAndTest\Get-Name.ps1" -Destination "$modulePath\Public\"
    Copy-Item -Path "$sourcePath\FunctionAndTest\Get-Helper.ps1" -Destination "$modulePath\Private\"
    Copy-Item -Path "$sourcePath\FunctionAndTest\Get-Name.Tests.ps1" -Destination "$modulePath\Test\"
    Copy-Item -Path "$sourcePath\Docs\ReadMe.md" -Destination "$modulePath\Docs\"
}

function Update-ToNextVersion {

    param(
        [string] $feedname,
        [string] $moduleName,
        [string] $modulePath,
        [pscredential] $credential
    )

    $module = Find-Module -Name $moduleName -Repository $feedname -Credential $credential -ErrorAction SilentlyContinue
    $currentVersion = New-Object System.Version($module.Version)
    $newVersion = New-Object System.Version("{0}.{1}.{2}" -f $currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1)
    Update-ModuleManifest -Path "$modulePath\$moduleName.psd1" -ModuleVersion $newVersion
}

#endregion

#==================#
#region PARAMTERS #
#=================#
## Local
$demoRoot = "C:\dev\training\Module Demo"
$repoName = "ModulePlayground"
$repoRoot = "$demoRoot\$repoName"
$moduleName = 'DemoModule'
$modulePath = "$repoRoot\$moduleName"
## Remote
$feedname = "TheMaw"
$feedurl = "https://pkgs.dev.azure.com/alsehr/_packaging/$feedname/nuget/v2"
$queueById = "alsehr@microsoft.com"
#---------

# Step 4 : Setup PAT with scope Packages-ReadWrite
$credential = Get-Credential -Message "Please provide a PAT for user alsehr@microsoft.com" -UserName "alsehr@microsoft.com"
#endregion

#===============#
#region CLEANUP #
#===============#
## Unregister Repos
nuget source remove -Name $feedName
Unregister-PSRepository -Name $feedname
## Remove module folder and content
Set-Location $demoRoot
Remove-Item -Path $repoRoot -Recurse -Force
#endregion

#===============#
#region PROCESS #
#===============#
# Step 1 : Create Project (e.g. Module Playground)
#---------

# Step 2 : Create Artifact Feed (e.g. TheMaw) 
#### Alternatives: e.g. local feed (any folder), a server location etc.
#---------

# Step 3 : Setup local feed
## Step 3.1 : nuget sources TODO: What's the difference in the two
$nugetSources = nuget sources
if (!("$nugetSources" -match $feedName)) {
    Write-Host 'Registering script folder as nuget source' -ForegroundColor Green
    nuget sources add -name $feedname -Source $feedurl -Username $queueById -Password (Read-Host -Prompt "Feed-PAT")
    Write-Host "Nuget source $feedname registered" -ForegroundColor Green
}
else { Write-Host "Nuget source already registered" -ForegroundColor Cyan }
## Step 3.2 : PSRepository
$regRepos = (Get-PSRepository).Name
if ($regRepos -notcontains $feedName) {
    Write-Host 'Registering script folder as PSRepository' -ForegroundColor Green
    Register-PSRepository $feedname -SourceLocation $feedurl -PublishLocation $feedurl -InstallationPolicy Trusted
    Write-Host "PSRepository $feedname registered" -ForegroundColor Green
}
else { Write-Host "PSRepository source already registered" -ForegroundColor Cyan }
#---------

# Step 4 Generate Module
Add-Module -modulePath $modulePath -moduleName $moduleName -sourcePath "$demoRoot\Material"
#---------

# Step 5: Publish Module
Publish-Module -Path "$modulePath" -NuGetApiKey 'VSTS' -Repository $feedname -Credential $credential -Force -Verbose
#---------

# Step 6 : Find Module
Find-Module -Name "*$moduleName*" -Repository $feedname -Credential $credential
#---------

# Step 7: Update Version to enable additional pushes
Update-ToNextVersion  -feedname $feedName -moduleName $moduleName -modulePath $modulePath -credential $credential
#---------
#endregion

#==================#
#region AUTOMATION #
#==================#
# Step 1: Create Remote Repo with Name "DemoModule"
# Step 2: Remove local folder for cloning
Remove-Item -Path $repoRoot -Recurse -Force
# Step 3: Clone to module folder
Set-Location $demoRoot
git clone "https://alsehr@dev.azure.com/alsehr/Module%20Playground/_git/ModulePlayground"
# Step 4: Copy necessary pipeline files to module pipeline folder
Add-Module -modulePath $modulePath -moduleName $moduleName -sourcePath "$demoRoot\Material"
# Step 5: Push files
Set-Location $modulePath
git status
git add .
git commit -m "Added repo files"
git push
# Step 6: Create Build Pipeline
# Step 7: Push change
#endregion