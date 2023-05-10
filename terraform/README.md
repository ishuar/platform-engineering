# Infrastrucutre

The management kubernetes cluster is created on [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/) and [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) using [Terraform](https://www.terraform.io/).

## FAQs

- **Why there is a dedicated direcotory for kubernetes cluster?**

This demonstrates the most reliable way to use the Kubernetes provider together with the Azurerm provider to create an AKS cluster. By keeping the two providers' resources in separate Terraform states, we can limit the scope of changes to either the AKS cluster or the Kubernetes resources. This will prevent dependency issues between the Azurerm and Kubernetes providers, since terraform's [provider configurations must be known before a configuration can be applied](https://www.terraform.io/docs/language/providers/configuration.html).

Known Issues on this subject:

> - [AWS-EKS-Kubernetes cluster unreachable](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234)
> - [Terraform invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable](https://github.com/Azure/AKS/issues/3495)

