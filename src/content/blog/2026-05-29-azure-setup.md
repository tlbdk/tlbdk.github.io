---
title: 'Setting up Azure as a GCP user'
description: ''
pubDate: 2026-05-29 12:08:00 +0200
categories: Azure, GCP
slug: astro/2026-05-29-azure-setup.html
heroImage: '/azure-gcp-setup-header.svg'
---

# Initial account setup

If you have created a Microsoft 365 Account before you started using Azure, it will have created a Billing Account, Billing Profile and Invoice Sections named after your company. For some reason you can't use this billing account for adding Azure subscriptions. I renamed this account to "Company (Microsoft 365)".

To work around this you need to create a new Billing Account, Billing Profile and Invoice Sections, the wizard for Creating a new subscription doing does this in the background but will use your name for the account names. So when the accounts have been you can rename them and added missing things like tax details, etc. Note that the "Cost Management + Billing" most likely will default to your "Company (Microsoft 365)" and refuse to switch to the other account, so use "Cost Management" instead to access the Billing account and when you want to add more subscriptions.

1. Create a new billing section in the Billing profile for each project, fx project1
2. Create a "Management group" for each environment for the project, fx project1-prod, project1-staging
3. Create a "Azure Subscription" under each "Management group" named after the management group, fx project1-prod, project1-staging
4. Create a "Resource group" under each subscription in the region you are planning to use named after the subscription plus "-region", fx project1-prod-swc (for Sweden Central)

fx. something like this:

- Tenant
  - prod (Management Group)
    - prod (Subscription)
      - prod-swc-k8s-main (Resource Group in Sweden Central)
        - main (Kubernetes Cluster)
        - fp-api (Managed Identity)
      - prod-swc-pg-main (Resource Group in Sweden Central)
        - prod-swc-pg-main (Managed Postgresql Server) (Global name)
  - staging (Management Group)
    - staging (Subscription)
      - staging-swc-k8s-main (Resource Group in Sweden Central)
        - main (Kubernetes Cluster)
        - fp-api (Managed Identity)
      - staging-swc-pg-main (Resource Group in Sweden Central)
        - staging-swc-pg-main (Managed Postgresql Server) (Global name)
  - build (Management Group)
    - build (Subscription)
      - build-swc-container-registry (Resource Group in Sweden Central)
        - buildswc (Container Registry) (Global name)
        - github-push
        - github-deploy
      - build-swc-tfstate (Resource Group in Sweden Central)
        - buildswctfstate (Storage account) (Global name)
          - tfstate (Storage Container)

## Ensure data is stored in EU

Create new tenant so you can ensure that data boundary is set to EU.

1. Allow main user access to granting "DataBoundaryTenantAdministrator" by going to "Micrsoft Entra ID"->"Properties" and under "Access management for Azure resources" select yes.
2. Login to the tenant:

```bash
az login --tenant <tenant id>
```

```bash
az login --allow-no-subscriptions --tenant <tenant id>
az ad user list # List accounts

az role assignment create --assignee "<Global Admin account>" --role d1a38570-4b05-4d70-b8e4-1100bcf76d12 --scope "/" # Assigned DataBoundaryTenantAdministrator to user
az data-boundary create --data-boundary EU --default default # Set EU data boundary
```

# Links

- Overview for GCP to Azure: https://learn.microsoft.com/en-us/azure/architecture/gcp-professional/
- Region selection: https://www.azurespeed.com/Azure/Latency?regions=northeurope,norwayeast,swedencentral,westeurope
