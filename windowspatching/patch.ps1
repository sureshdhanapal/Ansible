$update = new-object -com Microsoft.update.Session
$searcher = $update.CreateUpdateSearcher()
$pending = $searcher.Search("IsInstalled=0")
foreach($entry in $pending.Updates)
{
    Write-host "Title: " $entry.Title
    Write-host "Downloaded? " $entry.IsDownloaded
    Write-host "Description: " $entry.Description
    foreach($category in $entry.Categories)
    {
        Write-host "Category: " $category.Name
    }
    Write-host " "
}

