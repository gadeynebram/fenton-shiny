param(
    [string]$datadir = "S:\IZDev\Fenton"
)

# Check if the data directory exists
if (-not (Test-Path -Path $datadir -PathType Container)) {
    Write-Error "Data directory not found: $datadir"
    exit 1
}

# Copy CSV files from source to .\data, overwriting existing files
Write-Host "Copying CSV files from '$datadir' to '.\data'..."
Copy-Item -Path "$datadir\*.csv" -Destination ".\data\" -Force
Write-Host "CSV files copied successfully."

# First ensure that the container can be build and tag it.
podman build --no-cache -t uzgizshinyapps.azurecr.io/fenton .

# Login to azure
az login
# az acr login --name uzgizshinyapps  --expose-token

# retrieve a token from the container registry for podman to login.
$token = az acr login --name uzgizshinyapps --expose-token --output tsv --query accessToken
$token | podman login --username 00000000-0000-0000-0000-000000000000 --password-stdin uzgizshinyapps.azurecr.io

# push the tagged image.
podman push uzgizshinyapps.azurecr.io/fenton