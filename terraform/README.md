# Introduction.

This directory contains [Terraform](https://www.terraform.io/) configurations for the deployment of the management cluster on [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/) and [ArgoCD](https://argo-cd.readthedocs.io/en/stable/).

## Infrastructure Deployment

The first step is to create a kubernetes cluster which will act as our primary management control plane, in this project we are using [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/) for that purpose. On top of the kubernetes cluster we have used `ArgoCD` for GitOps solution , [ingress-nginx-controller](https://github.com/kubernetes/ingress-nginx) to controll incoming traffic to ArgoCD. The project also incorporates [External Secrets Operator](https://external-secrets.io/v0.8.1/) for secure secret handling, and utilizes [Azure Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) for seamless integration with Azure services.

For working of External Secrets Operator, an [azure key vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) , an [user assigned managed idenity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview#managed-identity-types) with read only access policies to the azure key vault are created.

Proactively, service principles and respective azure key vault secrets are created for the applications `external-dns`,`cert-manager` and `crossplane` which are managed via ArgoCD in future.

### Prerequisites

Before proceeding, make sure you have the following prerequisites installed and configured:

- **Must Have**

  - [`Terraform`](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

>> No hard dependency on terraform version but better to have it `1.3.0` or higher.

- **Good to Have** (optional)
  - [`Helm`](https://helm.sh/docs/intro/install/)( version `3` or higher)
  - [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
  - [`argocd-cli`](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli)
### Steps To Deploy

- Deploy the Azure Kubernetes Cluster and its dependecies.

```bash
git clone https://github.com/ishuar/platform-engineering.git
cd platform-engineering/terraform/azure-kubernetes-service
terraform init
terraform apply # use -auto-approve flag if need to auto approve the apply.
```

- Deploy ArgoCD, bootstrap-argocd-application and  nginx-ingress controller helm releases with proactive service principles and workload identity configuration for external-secret-operator.

```bash
cd ../terraform-kubernetes-resources
terraform init
terraform apply # use -auto-approve flag if need to auto approve the apply.
```

:warning:**IMPORTANT NOTE:** Must read Considerations !! :warning:

### Considerations

- Terraform configurred with one of the supported [authenticating-to-azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) methods.

- For azure Public DNS Zone you must have/use a domain which you own and have to configure the respective azure Nameservers for it on your domain hosting site.

- Current ArgoCD deployment(helm values) is configurred with GitHub Single Sign On, please remove the key `dex.config` and its value from `./helm-values/argo-cd.yaml` to disable the feature or set the correct values accordingly.

- Replace `server.ingress.hosts[0]` and `server.ingress.tls.hosts[0]` with the correct FQDN with the domain you own.

- ArgoCD is adding `bitnamicharts` OCI repository, remove `repositories.bitnami-external-dns.username` and `repositories.bitnami-external-dns.password` keys if you don't want to sign in while adding the repository, else set up the correct input variables.

## FAQs

- **Why there is a dedicated direcotory for kubernetes cluster and Kubernetes resources?**

This demonstrates the most reliable way to use the Kubernetes provider together with the Azurerm provider to create an AKS cluster. By keeping the two providers' resources in separate Terraform states, we can limit the scope of changes to either the AKS cluster or the Kubernetes resources. This will prevent dependency issues between the Azurerm and Kubernetes providers, since terraform's [provider configurations must be known before a configuration can be applied](https://www.terraform.io/docs/language/providers/configuration.html).

Known Issues on this subject:

> - [AWS-EKS-Kubernetes cluster unreachable](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234)
> - [Terraform invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable](https://github.com/Azure/AKS/issues/3495)
