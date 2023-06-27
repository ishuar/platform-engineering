# Argo CD Applications

This directory contains the configuration files managed by the ArgoCD and the `platform-engineering` bootstrap application deployed via terraform in [helm-releases.tf](../terraform/terraform-kubernetes-resources/helm-releases.tf)


## Definitions

Follwing is the definition of the files and directories within argocd tree.


- [`kustomization.yaml`](./kustomization.yaml) is used to include namespaces and the respective applications in the bootstrap application `platform-engineering`.
- [`namespaces.yaml`](./namespaces.yaml) is used to create namespaces prior to deploying the applications using the correct [`argo sync-wave`](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/#sync-phases-and-waves) and `node-selectors` annotations utilising [PodNodeSelector admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#podnodeselector) on azure kubernetes service.
- [`apps`](./apps/) contains the ArgoCD applications in [apps-of-apps-pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) with bootstrap applicaton `platform-engineering`.
- [`crossplane`](./crossplane/) contains the resources provisioned via [crossplane](https://github.com/crossplane/crossplane) in the respective cloud provider via crossplane-controller deployed within the kubernetes cluster.


## Sync Order

It is highly possible that even though after using sync-waves, argo applications are not synchronized in the correct order , following manual sequence of sync-operations is recommended for successfull deployment after syncing the bootstrap application `platform-engineering`.


1. All Namespaces: `external-dns`,`cert-manager`and `crossplane`.
2. ArgoCD Application: `external-secrets-operator`. (Only this at this stage)
3. `ClusterSecretStore`.
4. Configmaps: `external-dns-config-tpl` and `crossplane-config-tpl`.
5. ExternalSecrets: `external-dns-external-secret`, `cert-manager-external-secret` and `crossplane-external-secret`.
6. ArgoCD Applications: `external-dns`, `cert-manager` and `crossplane`
7. `ClusterIssuers`
8. Crossplane Provider: `provider-azure` this may take time, wait here untill this gets healthy.
9. Crossplane ProviderConfig: `crossplane-azure`.
10. ArgoCD Application: `azure-infrastructure-via-crossplane` (has to be last)


> **IMPORTANT NOTE:** Don't Skip the step unless the previous step is healthy/successfull and untill Step `7` ArgoCD will be available without TLS.