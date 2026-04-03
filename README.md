# Terraform Like a Pro

Demo repository for the conference talk **"Terraform Like a Pro"**.

It shows the evolution from manual Azure portal work to a fully automated,
shift-left IaC pipeline — using Azure API Management, Azure Functions,
GitHub Actions, Checkov, Infracost, and OPA (via conftest).

---

## Architecture

```
GitHub Actions
  ├── push dev  → Terraform deploy → Azure (dev stage)
  ├── push main → Terraform deploy → Azure (qa stage)
  └── pull_request
        ├── Checkov   — security & compliance scan
        ├── Infracost — cost delta comment on PR
        └── Conftest  — OPA custom policies

Azure (per environment)
  └── Resource Group
        ├── Storage Account         (Function App backing store)
        ├── App Service Plan (Y1)   (Consumption — serverless)
        ├── Linux Function App      (Node 18, HTTPS-only)
        └── API Management          (Consumption SKU)
              └── Hello API → GET / → Function App backend
```

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.7 | https://developer.hashicorp.com/terraform/install |
| Azure CLI | latest | https://learn.microsoft.com/en-us/cli/azure/install-azure-cli |
| conftest | ≥ 0.53 | https://www.conftest.dev/install/ |
| infracost | latest | https://www.infracost.io/docs/#quick-start |

---

## One-time: Bootstrap the Terraform Remote Backend

The remote state is stored in an Azure Blob Storage account.
This is the **only** manual step — everything else is automated.

```bash
# Login
az login

SUBSCRIPTION_ID="<your-subscription-id>"
az account set --subscription "$SUBSCRIPTION_ID"

# Create a dedicated resource group for Terraform state
az group create \
  --name rg-terraform-backend \
  --location "West Europe"

# Create a storage account (name must be globally unique, 3-24 lowercase alphanumeric)
az storage account create \
  --name stterraformbackend<suffix> \
  --resource-group rg-terraform-backend \
  --sku Standard_LRS \
  --https-only true \
  --min-tls-version TLS1_2

# Create the blob container
az storage container create \
  --name tfstate \
  --account-name stterraformbackend<suffix>
```

---

## Repo Secrets Required

Configure these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App registration Client ID (OIDC) |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription ID |
| `TF_STATE_STORAGE_ACCOUNT` | Name of the backend storage account |
| `INFRACOST_API_KEY` | Get free key at https://www.infracost.io |

### Setting up OIDC (Workload Identity)

```bash
# Create an App Registration
az ad app create --display-name "github-actions-terraform-like-a-pro"

APP_ID=$(az ad app list --display-name "github-actions-terraform-like-a-pro" --query "[0].appId" -o tsv)

# Create a service principal
az ad sp create --id "$APP_ID"

# Assign Contributor on the subscription (scope it to specific RGs in production!)
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Add federated credentials for each branch
# Repeat for: refs/heads/dev, refs/heads/main, and pull_request
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters '{
    "name": "github-dev-branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<your-org>/<your-repo>:ref:refs/heads/dev",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## Running Terraform Locally

```bash
cd terraform

az login
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"

# Init with the remote backend
terraform init \
  -backend-config="storage_account_name=stterraformbackend<suffix>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev.terraform.tfstate"

# Plan for dev
terraform plan -var-file="environments/dev.tfvars"

# Apply
terraform apply -var-file="environments/dev.tfvars"
```

---

## Running Quality Gates Locally

```bash
# Checkov
checkov -d terraform --framework terraform

# Infracost (requires INFRACOST_API_KEY)
infracost diff \
  --path terraform \
  --terraform-var-file terraform/environments/dev.tfvars

# OPA / conftest
cd terraform
terraform plan -var-file="environments/dev.tfvars" -out=tfplan
terraform show -json tfplan > ../tfplan.json
cd ..

conftest test tfplan.json --policy policies/opa --all-namespaces
```

---

## Branch → Stage Mapping

| Branch | Stage | tfvars |
|--------|-------|--------|
| `dev` | dev | `environments/dev.tfvars` |
| `main` | qa | `environments/qa.tfvars` |

Pull requests run the quality gates (Checkov, Infracost, OPA) but **do not deploy**.

---

## Talk Narrative

This repo corresponds to the final stage of the talk — the full solution:

1. **No IaC** — manual portal clicks, copy-paste between environments, no audit trail
2. **Local Terraform** — reproducible, but only one person can deploy, no history
3. **Terraform + GitHub** — pull requests, audit trail, but manual deployment
4. **Terraform + GitHub Actions** — automated deployment per branch, remote backend, OIDC
5. **Shift-left quality gates** ← *this repo* — Checkov + Infracost + OPA in every PR
