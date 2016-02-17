$basePath=Split-Path -Parent $MyInvocation.MyCommand.Definition

function export($filePath)
{
    $index=$filePath.LastIndexOf("\")+1
    if($index -ne 0){
        $fileName=$filePath.Substring($index)
        Write-Host $fileName
        $path=$basePath+'\package\'+$filePath.Substring(0,$index)
        if(Test-Path $path){
            
        }
        else{
            New-Item $path -type Directory
        }
        Copy-Item $filePath $path
    }
}

svn up

svn status > file_list.txt

Remove-Item $basePath'\package\'* -recurse -Force

$log=Get-Content file_list.txt
foreach($diff in $log){
    if($diff){
        $state=$diff.Substring(0,1)
        $path=$diff.Substring($diff.IndexOf($state)+1).Trim()
        switch($state)
        {
            # 加入版本库
            ? {svn add $path }
            # 删除版本库
            ! {svn delete $path }
        }
    }
}

svn status > file_list.txt

$log=Get-Content file_list.txt

foreach($diff in $log){
    if($diff){
        $state=$diff.Substring(0,1)
        $path=$diff.Substring($diff.IndexOf($state)+1).Trim()
        switch($state)
        {
            # 加入版本库
            ? {svn add $path;export $path }
            # 删除版本库
            ! {svn delete $path }
            default { export $path }
        }
    }
}

$date=Get-Date -Format 'yy-M-d H:m:s'
svn commit -m $date' 增量包'

function ZipFiles($zipfilename, $sourcedir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}
$zipPath=$basePath+"\package.zip"

if(Test-Path $zipPath){
    Remove-Item $zipPath
}

ZipFiles $basePath"\package.zip" $basePath'\package\'

pause
