function Convert-FolderContentToMarkdownTableOfContents {
    param (
        [string]$BaseFolder,
        [string]$FiletypeFilter,
        [int]$Level = 0
    )
 
    $nl = [System.Environment]::NewLine
    $TOC = ""
 
    $repoFolderStructure = Get-ChildItem -Path $BaseFolder -Directory | Where-Object Name -NotMatch "_site|pics|_posts|styles"
 
    foreach ($dir in ($repoFolderStructure | Sort-Object -Property Name)) {
        # Check if ix.md exists in the current directory
        $ixFile = Get-ChildItem -Path $dir.FullName -Filter "ix.md" -ErrorAction SilentlyContinue

        if ($ixFile) {
            # If ix.md exists, create a link for the folder using the full path including the base folder
            $relativePath = $dir.FullName.Replace((Get-Item $BaseFolder).Parent.FullName, "").TrimStart("\").Replace("\", "/")
            $suffix = "https://mars9n9.github.io/cakes/$relativePath"
            $TOC += "$(""  " * $Level)* [$($dir.Name)]($([uri]::EscapeUriString(""$suffix/ix.html"")))$nl"
        } else {
            # If ix.md does not exist, show the folder name as plain text
            $TOC += "$(""  " * $Level)* $($dir.Name)$nl"
        }

        # Recursively call the function for subfolders
        $TOC += Convert-FolderContentToMarkdownTableOfContents -BaseFolder $dir.FullName -FiletypeFilter $FiletypeFilter -Level $($Level+1)
        
        $repoStructure = Get-ChildItem -Path $dir.FullName -Filter $FiletypeFilter

        foreach ($md in ($repoStructure | Where-Object Name -NotMatch "ix.md" | Sort-Object -Property Name)) {
            $file_data = Get-Content "$($md.Directory.ToString())\$($md.Name)" -Encoding UTF8
            if ($file_data.count -gt 0) {
                $fileName = $file_data[0] -replace "# "
            } else {
                $fileName = $($md.Name)
            }
            $relativePath = $md.Directory.ToString().Replace((Get-Item $BaseFolder).Parent.FullName, "").TrimStart("\").Replace("\", "/")
            if ($Level -eq 0){
                $suffix = "https://mars9n9.github.io/cakes" + $($md.Directory.ToString().Replace($BaseFolder, [string]::Empty)).Replace("\", "/")
            } else {
                $suffix = "https://mars9n9.github.io/cakes/$relativePath"   
            }
            $TOC += "$(""  " * ($Level + 1))* [$fileName]($([uri]::EscapeUriString(""$suffix/$($md.Name.Replace(".md", ".html"))"")))$nl"
        }
    }
 
    return $TOC
}

# Get the current directory
$currentDirectory = Get-Location
Convert-FolderContentToMarkdownTableOfContents -BaseFolder $currentDirectory -FiletypeFilter "*.md" | Out-File (Join-Path $currentDirectory "index.markdown") -Encoding UTF8
