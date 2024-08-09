function Convert-FolderContentToMarkdownTableOfContents{
    param (
        [string]$BaseFolder,
        [string]$FiletypeFilter,
		[int]$Level = 0
    )
 
    $nl = [System.Environment]::NewLine
    $TOC = ""
 
    $repoFolderStructure = Get-ChildItem -Path $BaseFolder -Directory | Where-Object Name -NotMatch "_site|pics|_posts|styles"
 
    foreach ($dir in ($repoFolderStructure | Sort-Object -Property Name)) {
		
		if ($Level -eq 0){
		$suffix = "https://mars9n9.github.io/cakes/" + $($dir.Name)}
		else {
			$suffix = "https://mars9n9.github.io/cakes/" + $($BaseFolder.Split("\")[-1]) + "/" + $($dir.Name)}
		
        $TOC += "$(""  ""*$($Level))* [$($dir.Name)]($([uri]::EscapeUriString(""$suffix/$(""ix.md"".Replace("".md"", "".html""))""))) $nl"
		$TOC += Convert-FolderContentToMarkdownTableOfContents -BaseFolder $dir.FullName -FiletypeFilter $FiletypeFilter -Level $($Level+1)
        $repoStructure = Get-ChildItem -Path $dir.FullName -Filter $FiletypeFilter
 
        foreach ($md in ($repoStructure | Where-Object Name -NotMatch "ix.md"| Sort-Object -Property Name)) {
            $file_data = Get-Content "$($md.Directory.ToString())\$($md.Name)"  -Encoding UTF8
			if ($file_data.count -gt 0){
			$fileName = $file_data[0] -replace "# "}
			else
			{
				$fileName = $($md.Name)
			}
			if ($Level -eq 0){
			$suffix = "https://mars9n9.github.io/cakes" + $($md.Directory.ToString().Replace($BaseFolder, [string]::Empty)).Replace("\", "/")}
			else {
				$suffix = "https://mars9n9.github.io/cakes/" + $($BaseFolder.Split("\")[-1]) + $($md.Directory.ToString().Replace($BaseFolder, [string]::Empty)).Replace("\", "/")}
            $TOC += "$(""  ""*$($Level+1))* [$fileName]($([uri]::EscapeUriString(""$suffix/$($md.Name.Replace(".md", ".html"))"")))$nl"
        }
    }
 
    return $TOC
}
# Get the current directory
$currentDirectory = Get-Location
Convert-FolderContentToMarkdownTableOfContents -BaseFolder $currentDirectory -BaseURL "" -FiletypeFilter "*.md" | Out-File (Join-Path $currentDirectory "index.markdown") -Encoding UTF8
