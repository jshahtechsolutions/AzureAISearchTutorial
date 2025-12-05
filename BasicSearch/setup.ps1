# Define variables
# execute this file like .\setup.ps1
$resourceGroupName = "LearningRG" # Replace with your resource group name
$storageAccountName = "jcpdfsblobstorage" # Replace with your storage account name
$containerName = "travelfiles" # Must match the default or specified name in the Bicep file
$bicepFile = "main.bicep" #".\main.bicep"
$sourceFolder = ".\data\travelinfo" # Replace with the local path to your files

# 1. Connect to Azure (if not already connected)
az login

# 2. Deploy the Bicep file to create the container
Write-Host "Deploying Bicep file to create container..."
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $bicepFile `
    -storageAccountName $storageAccountName `
    -containerName $containerName

Write-Host "Container '$($deployment.Outputs.containerNameOutput.Value)' created successfully."

# 3. Get the storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$ctx = $storageAccount.Context

# 4. Upload files from the local folder to the container
Write-Host "Uploading files from $sourceFolder to container $containerName..."
$files = Get-ChildItem -Path $sourceFolder -File

foreach ($file in $files) {
    Set-AzStorageBlobContent `
        -File $file.FullName `
        -Container $containerName `
        -Blob $file.Name `
        -Context $ctx `
        -Force
    Write-Host "Uploaded $($file.Name)"
}

Write-Host "All files uploaded successfully."