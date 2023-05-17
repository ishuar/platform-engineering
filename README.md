<!-- PROJECT SHIELDS -->
<!--
*** declarations on the bottom of this document
-->
[![License][license-shield]][license-url] [![Contributors][contributors-shield]][contributors-url] [![Issues][issues-shield]][issues-url] [![Forks][forks-shield]][forks-url] [![Stargazers][stars-shield]][stars-url]

### Table Of Contents
- [About The Project](#about-the-project)
- [Usage](#usage)
  - [Directory Structure](#directory-structure)
  - [Directory **Tree**](#directory-tree)
    - [`terraform`](#terraform)
    - [`argocd`](#argocd)
    - [`scripts`](#scripts)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)



<div id="top"></div>

<!-- PROJECT LOGO -->
<br />
<div align="center">

   <a href="https://github.com/ishuar/platform-engineering">
    <img src="https://github.com/ishuar/platform-engineering/blob/main/.vscode/extras/platform-engineering.png" alt="Logo" width="800" height="300">
  </a>

  <h1 align="center"><strong>Platform Engineering</strong></h1>
  <p align="center">
    Platform engineering is the discipline of designing and building toolchains and workflows that enable self-service capabilities for software engineering organizations in the cloud-native era.
    <br/>
    <a href="https://github.com/ishuar/platform-engineering/issues"><strong>Report Bug</a></strong> or <a href="https://github.com/ishuar/platform-engineering/issues"><strong>Request Feature</a></strong>
    <br/>
    <br/>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

This repository is a collection of code, scripts, and configuration files that enable the creation and management of a scalable, secure, and reliable cloud infrastructure. The repository includes [Terraform](https://developer.hashicorp.com/terraform/intro) configurations that define the infrastructure as code, including the creation of an Azure Kubernetes Cluster and associated resources such as virtual networks, resource groups etc.

In addition, the repository includes [ArgoCD](https://argo-cd.readthedocs.io/en/stable/), a GitOps tool that automates the deployment of applications and services to the Kubernetes cluster. ArgoCD enables continuous delivery by automatically synchronizing the Kubernetes cluster with the Git repository where the application code resides.

The combination of Terraform and ArgoCD provides a powerful foundation for creating and managing cloud-based infrastructure and deploying applications with ease and efficiency.

<!-- USAGE -->
## Usage

Following points will help you to understand `How To use this repository?`.

### Directory Structure

This repo is distributed in three major directories.

- [terraform](https://github.com/ishuar/platform-engineering/tree/main/terraform)
- [argocd](https://github.com/ishuar/platform-engineering/tree/main/argocd)
- [scripts](https://github.com/ishuar/platform-engineering/tree/main/scripts)

<details>
  <summary>Click to view tree structure</summary>

### Directory **Tree**
```bash
.
├── argocd
│   ├── apps
│   │   ├── azure-infrastructure-crossplane
│   │   ├── cert-manager
│   │   ├── crossplane
│   │   ├── external-dns
│   │   └── external-secrets-operator
│   └── crossplane
│       └── azure
├── scripts
└── terraform
    ├── azure-kubernetes-service
    ├── github
    └── terraform-kubernetes-resources
        └── helm-values
```
</details>


#### `terraform`

This directory is further divided into two subdirectories

- [`azure-kubernetes-service`](https://github.com/ishuar/platform-engineering/tree/main/terraform/azure-kubernetes-service)
- [`terraform-kubernetes-resources`](https://github.com/ishuar/platform-engineering/tree/main/terraform/terraform-kubernetes-resources)
</br>

  - The `azure-kubernetes-service` directory uses the [Terraform aks module](https://github.com/ishuar/terraform-azure-aks) for creating an Azure Kubernetes Cluster and explicit terraform resources for its dependencies such as `resource group` and `network`.

  - The `terraform-kubernetes-resources` directory include [`terraform helm releases`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) for the GitOps utility `ArgoCd` , [`ingress-nginx-controller`](https://github.com/kubernetes/ingress-nginx/) and supporting kubernetes resources. This folder also includes the terraform configuration for the concept of [`AKS workload idenity`](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) for the secret management controller [`external-secrets-operator`](https://external-secrets.io/v0.8.1/) used in this project.

#### `argocd`

This directory is further divided into into sub directories.

- [`apps`](https://github.com/ishuar/platform-engineering/tree/main/argocd/apps)
- [`crossplane`](https://github.com/ishuar/platform-engineering/tree/main/argocd/crossplane)


  - `apps` contain other directories which together makes an ArgoCD [application](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) definitions.
  - `crossplane` contain another `azure` sub-dir with resource group config deployed via crossplane using azure kubernetes cluster on Azure Portal.

#### `scripts`

This directory is meant to contain any automation script which may be useful in the project context. Currently a shell script to check/install the [`Kustomize`](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) program on the local machine.



> Please have a look at each directory's `README` for details on how to use this repository code.

- [argocd-readme](https://github.com/ishuar/platform-engineering/blob/main/argocd/README.md)
- [terraform](https://github.com/ishuar/platform-engineering/blob/main/terraform/README.md)

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have any suggestion that would make this project better, feel free to  fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement" with your suggestion.

**⭐️Don't forget to give the project a star! Thanks again!⭐️**

See [`CONTRIBUTING`](/CONTRIBUTING.md) for more information.

<!-- LICENSE -->
## License

Released under [MIT](/LICENSE) by [@ishuar](https://github.com/ishuar).

<!-- CONTACT -->
## Contact

- 👯 [LinkedIn](https://www.linkedin.com/in/ishuar/)

<p align="right"><a href="#top">Back To Top ⬆️</a></p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-url]: https://github.com/ishuar/platform-engineering/graphs/contributors
[contributors-shield]: https://img.shields.io/github/contributors/ishuar/platform-engineering?style=for-the-badge

[forks-url]: https://github.com/ishuar/platform-engineering/network/members
[forks-shield]: https://img.shields.io/github/forks/ishuar/platform-engineering?style=for-the-badge

[stars-url]: https://github.com/ishuar/platform-engineering/stargazers
[stars-shield]: https://img.shields.io/github/stars/ishuar/platform-engineering?style=for-the-badge

[issues-url]: https://github.com/ishuar/platform-engineering/issues
[issues-shield]: https://img.shields.io/github/issues/ishuar/platform-engineering?style=for-the-badge

[license-url]: https://github.com/ishuar/platform-engineering/blob/main/LICENSE
[license-shield]: https://img.shields.io/github/license/ishuar/platform-engineering?style=for-the-badge