param(
    [string]$datadir = "S:\IZDev\Fenton",
    [string]$tag = "latest"
)

# Stop script execution on any error
$ErrorActionPreference = "Stop"

# Check if the data directory exists
if (-not (Test-Path -Path $datadir -PathType Container)) {
    Write-Error "Data directory not found: $datadir"
    exit 1
}

# Copy CSV files from source to .\data, overwriting existing files
Write-Host "Copying CSV files from '$datadir' to '.\data'..."
Copy-Item -Path "$datadir\*.csv" -Destination ".\data\" -Force
Write-Host "CSV files copied successfully."

# Start the podman machine
podman machine start

# First ensure that the container can be build and tag it.
podman build --no-cache -t uzgizshinyapps.azurecr.io/fenton:$tag .
if ($LASTEXITCODE -ne 0) { throw "Podman build failed" }

# Login to azure
az login
# az acr login --name uzgizshinyapps  --expose-token

# retrieve a token from the container registry for podman to login.
$token = az acr login --name uzgizshinyapps --expose-token --output tsv --query accessToken
$token | podman login --username 00000000-0000-0000-0000-000000000000 --password-stdin uzgizshinyapps.azurecr.io

# push the tagged image.
Write-Host "Pushing image to Azure Container Registry with tag '$tag'..."
podman push uzgizshinyapps.azurecr.io/fenton:$tag
if ($LASTEXITCODE -ne 0) { throw "Podman push failed for '$tag' tag" }
Write-Host "Successfully pushed image with tag '$tag'" -ForegroundColor Green