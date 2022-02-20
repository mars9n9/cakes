function Convert-FolderContentToMarkdownTableOfContents{
<#
.SYNOPSIS
Create a Table of Contents in markdown

.DESCRIPTION
This function can be used to generate a markdown file that contains a Table of Contents based on the contents of a folder

.PARAMETER BaseFolder
It’s the folder’s location on the disk

.PARAMETER BaseURL
to build the URL for each file. This will be added as a link

.PARAMETER FiletypeFilter
to filter the files on the folder

.EXAMPLE
Convert-FolderContentToMarkdownTableOfContents -BaseFolder "D:\Github\<module folder>" -BaseURL "https://github.com/<user>/<repository>/tree/master" -FiletypeFilter "*.md"

.NOTES
https://claudioessilva.eu/2017/09/18/generate-markdown-table-of-contents-based-on-files-within-a-folder-with-powershell/
#>    
    
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

Convert-FolderContentToMarkdownTableOfContents -BaseFolder  "D:\Documents\GitHub\cakes" -BaseURL "" -FiletypeFilter "*.md"  | Out-File "D:\Documents\GitHub\cakes\index.md" -Encoding UTF8