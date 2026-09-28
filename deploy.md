# Install Azure CLI
## Windows
```winget install Microsoft.AzureCLI```

## Linux (Ubuntu / Debian)
```curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash```

## macOS
```brew update && brew install azure-cli```

# Get Azure Deployment Credentials
## Setup Service Principle
az ad sp create-for-rbac --name "YourSPName" --role contributor --scopes /subscriptions/yourSubscriptionId

Add this as a repo secret in GitHub

# Implementation
Create a GitHub Repo and after adding the credentials to the repo secrets, remove the ```disabled``` after the ```.github/workflows/deployAzureResources.yml.disabled``` push this code to the repo. 