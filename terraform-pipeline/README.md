# Terraform Pipeline Practice

## 📁 Structure
```
terraform-pipeline/
├── azure-pipelines.yml     ← Main pipeline (4 stages)
└── terraform/
    ├── main.tf             ← Resource Group resource
    └── variables.tf        ← Input variables with validation
```

---

## 🔄 Pipeline Stages Overview

| # | Stage | Key Tasks |
|---|-------|-----------|
| 1 | **Terraform Plan** | Install TF → `init` → `validate` → `fmt -check` → `plan` → publish artifact |
| 2 | **Security Scan** | tfsec (static analysis) + checkov (compliance) → publish JUnit results |
| 3 | **Manual Approval** | ADO Environment gate – a human must approve before apply |
| 4 | **Terraform Apply** | Download plan artifact → `init` → `apply` with saved plan |

---

## ⚙️ One-Time ADO Setup (before first run)

### 1. Create a Service Connection
- **Project Settings** → **Service connections** → **New service connection**
- Type: **Azure Resource Manager** → Service Principal
- Name it: `your-azure-service-connection`

### 2. Create the Azure Storage Account (Terraform Backend)
```bash
# Run once in Azure CLI
az group create --name rg-terraform-state --location eastus
az storage account create --name sttfstatedev001 --resource-group rg-terraform-state --sku Standard_LRS
az storage container create --name tfstate --account-name sttfstatedev001
```

### 3. Create the ADO Environment + Approval Gate
- **Pipelines** → **Environments** → **New environment**
- Name it: `production-approval`
- Click the `...` menu → **Approvals and checks** → **Approvals**
- Add yourself (or a reviewer) as the approver

### 4. Update Pipeline Variables
Edit `azure-pipelines.yml` and replace:
```yaml
azureServiceConnection: 'your-azure-service-connection'  # ← your real connection name
backendStorageAccount:  'sttfstatedev001'                # ← your real storage account
```

---

## 🚀 Run the Pipeline
1. Push this folder to your ADO repo (`New`)
2. **Pipelines** → **New Pipeline** → **Azure Repos Git** → select `New` repo
3. Select **Existing Azure Pipelines YAML file**
4. Path: `/terraform-pipeline/azure-pipelines.yml`
5. **Run** → watch each stage in the UI!

---

## 🧠 Key Concepts Practiced

### Stage 1 – Terraform Plan
| Command | What it does |
|---------|-------------|
| `terraform init` | Downloads providers, configures backend |
| `terraform validate` | Checks syntax & variable types |
| `terraform fmt -check` | Ensures code is properly formatted |
| `terraform plan -out=tfplan` | Generates an execution plan (saved as artifact) |

### Stage 2 – Security Scanning
| Tool | Purpose |
|------|---------|
| **tfsec** | Detects misconfigurations (open ports, no encryption, etc.) |
| **checkov** | Policy-as-code compliance checks (CIS benchmarks, etc.) |

### Stage 3 – Manual Approval
- Uses ADO **Environments** with **Approval checks**
- Pipeline pauses and sends notification to approver(s)
- Approver reviews Plan output in Stage 1 before clicking Approve

### Stage 4 – Terraform Apply
- Downloads the **exact same plan artifact** from Stage 1
- Uses `apply <plan-file>` — no surprises, applies only what was planned
- Runs inside the same `deployment` job (tracked in ADO environment history)
