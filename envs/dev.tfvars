apps = [
  {
    name          = "summaries-worker"
    image         = "aoaiseccr.azurecr.io/summaries-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
  },
  {
    name          = "classify-worker"
    image         = "aoaiseccr.azurecr.io/classify-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
  },
  {
    name          = "extract-worker"
    image         = "aoaiseccr.azurecr.io/extract-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
  },
  {
    name          = "redact-worker"
    image         = "aoaiseccr.azurecr.io/redact-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
  },
  {
    name          = "translate-worker"
    image         = "aoaiseccr.azurecr.io/translate-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
  }
]