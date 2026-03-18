# --- FORCE ACR NAME TO BE SET ---
$AcrName = "aoaidevacraa06.azurecr.io"

Write-Host "Using ACR: [$AcrName]" -ForegroundColor Green

# --- WORKER LIST ---
$workers = @(
    "summaries-worker"
    "classify-worker"
    "extract-worker"
    "redact-worker"
    "translate-worker"
)

Write-Host "Workers count: $($workers.Count)"
foreach ($worker in $workers) { Write-Host "Worker=[$worker]" }

Write-Host "=== Building and pushing worker images ===" -ForegroundColor Cyan

foreach ($worker in $workers) {

    $path = "workers/$worker"

    # 🔍 DIAGNOSTIC LINE ADDED HERE
    Write-Host "RAW IMAGE LINE: [$AcrName/$worker:latest]"

    $image = $AcrName + "/" + $worker + ":latest"

    Write-Host "`n--- Processing $worker ---" -ForegroundColor Yellow
    Write-Host "Image tag: $image" -ForegroundColor DarkGray
    Write-Host "DEBUG: worker=[$worker] image=[$image]"

    if (-Not (Test-Path $path)) {
        Write-Host "Directory not found: $path" -ForegroundColor Red
        exit 1
    }

    # Ensure start.sh is executable
    $startScript = Join-Path $path "start.sh"
    if (Test-Path $startScript) {
        Write-Host "Ensuring start.sh is executable..."
        git update-index --chmod=+x $startScript
    }

    Write-Host "Building image: $image" -ForegroundColor Cyan
    docker build -t $image $path
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed for $worker" -ForegroundColor Red
        exit 1
    }

    Write-Host "Pushing image: $image" -ForegroundColor Cyan
    docker push $image
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Push failed for $worker" -ForegroundColor Red
        exit 1
    }

    Write-Host "$worker complete." -ForegroundColor Green
}

Write-Host "`n=== All worker images built and pushed successfully ===" -ForegroundColor Green