+++
title = "Google cloud functions"
outputs = ["Reveal"]
+++

# Google cloud functions
---
# Google cloud functions
- Serverless
- Docker-less

---
# Supported languages
- Node.js 8 & Node.js 10
- Python
- Go 1.11 & Go 1.13

---
# Code structure
```
.
├── function.go --> function with http.HandlerFunc
├── go.mod
└── shared/
    └── shared.go
```
---
# http.Handlerfunc

```go
type HandlerFunc func(http.ResponseWriter, *http.Request)
```

example:

```go
func ServeHTTP(w http.ResponseWriter, r *http.Request) {
  w.Write([]byte("Hello, world"))
}
```

---
# Deploying from github actions
Need: github service account with `Cloud Functions Admin` permissions

- go to [cloud console iam admin service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts?project=gopper)
- click `Create Service account` 
- give service account `Cloud Functions Admin` permissions
---
# Deploying from github actions
- download access key
- Put access key in `GCLOUD_SERVICE_KEY` secret in repo

---
# Github actions
```yaml
name: cloud-function-deploy

on:
  push:
    branches: [ master ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Setup - gcloud / gsutil
        uses: GoogleCloudPlatform/github-actions/setup-gcloud@master
        with:
          service_account_key: ${{ secrets.GCLOUD_SERVICE_KEY }}
          export_default_credentials: true
      - name: Set default project
        run: gcloud config set core/project <PROJECT NAME>
      - name: Deploy
        run: |
          gcloud functions deploy <FUNCTION NAME> \
                 --entry-point=ServeHTTP \
                 --runtime=go113 \
                 --trigger-http \
                 --allow-unauthenticated
      - name: Set permissions
        run: |-
          gcloud functions add-iam-policy-binding <FUNCTION NAME>\
            --member="allUsers" \
            --role="roles/cloudfunctions.invoker"
```
more options [here](https://cloud.google.com/sdk/gcloud/reference/functions/deploy)

---
# Push to master

- Should be deployed at `<region>-<projectid>cloudfunctions.net/<function name>`

```bash
curl <region>-<projectid>cloudfunctions.net/<function name>
> Hello, World!
```