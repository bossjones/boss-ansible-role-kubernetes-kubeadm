# vagrant, dns, and kubernetes google search

https://www.google.com/search?ei=qogDXLGTEMeijwT9wb3ABA&q=vagrant+%22cluster.local%22&oq=vagrant+%22cluster.local%22&gs_l=psy-ab.3...2596.6015..6330...0.0..0.464.464.4-1......0....1..gws-wiz.AlI7x6CkUKA

Search: vagrant "cluster.local"

* https://dzone.com/articles/advanced-virtualbox-and

* https://github.com/mattes/vagrant-dnsmasq/issues/21

* https://github.com/futuware/kapellmeister/blob/3ac0a1bc857a919e718c7f7b728f0cff460e8849/Vagrantfile

* [YO THIS IS THE ONE !!!!!!!!!! OpenShift / K8s : DNS Configuration Explained](http://www.ksingh.co.in/blog/2017/10/04/openshift-dns-configuration-explained/)

* [wildcard DNS in localhost development dnsmasq dnsmasq_setup_osx](https://gist.github.com/eloypnd/5efc3b590e7c738630fdcf0c10b68072)

* [How To Inspect Kubernetes Networking](https://www.digitalocean.com/community/tutorials/how-to-inspect-kubernetes-networking)

* [Configure DNS Wildcard with Dnsmasq Service](https://qiita.com/bmj0114/items/9c24d863bcab1a634503)

* [How to setup wildcard dev domains with dnsmasq on a mac](https://hedichaibi.com/how-to-setup-wildcard-dev-domains-with-dnsmasq-on-a-mac/)

* https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-36598b5e8408

* https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-part-2-bac431095706

* https://medium.com/@joatmon08/application-logging-in-kubernetes-with-fluentd-4556f1573672

* [FUN WITH KUBERNETES DNS](http://www.akins.org/posts/fun-with-dns/)

* https://rsmitty.github.io/KubeDNS-Tweaks/

* https://github.com/letsencrypt/boulder

* [How To Set Up an Elasticsearch, Fluentd and Kibana (EFK) Logging Stack on Kubernetes](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes)

* [An Introduction to the Kubernetes DNS Service](https://www.digitalocean.com/community/tutorials/an-introduction-to-the-kubernetes-dns-service)

# changing the kublet configuration

SOURCE: https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-part-2-bac431095706

```
$ less /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=0"
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true --cert-dir=/var/lib/kubelet/pki"
Environment="KUBELET_EXTRA_ARGS=--node-ip=<worker IP address>"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CGROUP_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS
```



# K8 components

SOURCE: https://rafishaikblog.wordpress.com/2017/10/17/kubernetes-cluster-with-vagrant-virtual-box/

```
etcd – A highly available key-value store for shared configuration and service discovery.
flannel – An etcd backed network fabric for containers.
kube-apiserver – Provides the API for Kubernetes orchestration.
kube-controller-manager – Enforces Kubernetes services.
kube-scheduler – Schedules containers on hosts.
kubelet – Processes a container manifest so the containers are launched according to how they are described.
kube-proxy – Provides network proxy services.
```


```
root@master:/etc/default# cat /proc/5109/environ
LANG=en_US.UTF-8PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/binKUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.confKUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yamlKUBELET_EXTRA_ARGS=KUBELET_KUBEADM_ARGS=--cgroup-driver=cgroupfs --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cniroot@master:/etc/default#

```


# List files installed by apt-get

```
# dpkg-query -L kubeadm
/.
/usr
/usr/bin
/usr/bin/kubeadm
/etc
/etc/systemd
/etc/systemd/system
/etc/systemd/system/kubelet.service.d
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```



# kubelet debugging research


### /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

```
Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

### /var/lib/kubelet/kubeadm-flags.env

```
root@master:~# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS=--cgroup-driver=cgroupfs --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cni
root@master:~#
```


### /etc/default/kubelet

```
root@master:~# cat /etc/default/kubelet
KUBELET_EXTRA_ARGS=
root@master:~#
```

### /etc/kubernetes/kubelet.conf

```
root@master:~# cat /etc/kubernetes/kubelet.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNE1USXdNVEl3TXpJeU9Wb1hEVEk0TVRFeU9ESXdNekl5T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmt4CmgxeVhWbTVSYmQvQytNSTBqQXNmNExlRkNrQ2xEdzFMcXR4ZHcrK05FaUptcU0xb2V0VW15VkRxNlowK3I5SXAKcnhGMTIrSzJkR09SSjNYbWFzRDhUNEJXYnB4U00yZHNMdDVuellkQlE5U2dRTVlFbXMrU2svN3c1ZndiRlZWTgozQkU3UzZ4UVFqL1NCZXFGQVJVd2VsMFpVN2xCYnlDQ3d1RElscUZJcUdSS0FLUFkvd01wL0hrRHhJK3hBcTJLCkJEeVpSYzNtNHNqOWNUaFJSWEQyQ2dvc0dQWGMwUzJFQ1QzZmNvSE5QMlYzLzZselBpaENtYmpZVWlZSnNLSlMKMFFqWjF2aEZaWUJmUDZmekRYeUcvZjJmNXBvNU5ZQ2VlWjdqZmx0dy9IZW5EVE5OQndLSVNHeUdPRVNjT0RJdAp6MGcrc1JFTFVkT2x3V3J4bG9NQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFEenpnWWtNUjQ5N2JpUzZ3YWtVUjBaNGpQblMKYnMvaDJPNFBBU3FBL1Jwa0JhQ0tHcDJHYk9UbytFdDhONGtYV3R5K1ZibS80RXJGZjU5MmNSZDNaTzE1eWVWZgo2Vk9UL3VobkVJUnBER1Fsb3ZUTEt5R2g0UTVHNlhWOVBHSUd4M3Z0dFNIRTJkYzN4OGFsdFNZZ0cyR1o1c3dTCk45WFRwN1ZyRHZxeFZTZlpYamdqTjJHZE1ZaEthS1pmb3ZVTnNqSlNycVpCQU5rUjl5VDV4MDZZbVNOSGxqRE0KYlBSbjlCU3hEeFQxZW5ndnR1bnA1NktheUVEOEJmOE5hWTRnS1RVNmdseW9xOFlZYXJYYk5WVnIxZk5aelVZbApGNWdsb3pqK2pnU3YvbVdsc2F0TFpBSlp1NVJEcFc5SUs4WkJnVDc3ZUNMbEIxWGdjRUFIanlSL3d1ND0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://192.168.50.101:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: system:node:master
  name: system:node:master@kubernetes
current-context: system:node:master@kubernetes
kind: Config
preferences: {}
users:
- name: system:node:master
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM4akNDQWRxZ0F3SUJBZ0lJZnVGNWVHbUpiTGd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB4T0RFeU1ERXlNRE15TWpsYUZ3MHhPVEV5TURFeU1ETXlNekphTURReApGVEFUQmdOVkJBb1RESE41YzNSbGJUcHViMlJsY3pFYk1Ca0dBMVVFQXhNU2MzbHpkR1Z0T201dlpHVTZiV0Z6CmRHVnlNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTlVZkhFenhYQ2ZLRTUxMGIKVjdSTXhRTzhJWUxNYWtpVURad2dQVlNId2V3QnN6WUF4a2NJR2VLT29yMlNRemphZndaS0xpSHVhb2hORGMySAovcVNXZVI4Y3NkSThMRWVFaVJBS3lEMGo1bGgxVVdQSjhJMlNKaHNPcExMbGY0S0tUSWRTYm9xZEw2a1hDcDFuCjgwR3lZc3VQeHdYYVhaYjBhUGxUTkRmNnNWejlYL3ZHeERQSGUwbFZCcGNKdlVkS2ZGd29YYU96MjlldWVRVmIKV3R2N2FPS3pUWm5raWtEME14Q2RiV0NaK2FiZGhEUUtPK2NsbjJ5cEE2a2x0eUt5ZGJ4MW5NcFMvaXlhZWdVUQpSMkM3V25pTU52WHNmNERENFpZOWswUytHamw4QlByL2J6V0p3dFByVjMxM2IzVE1DdENHVmFuaDNuL1B1TGdJCkhWd0VtUUlEQVFBQm95Y3dKVEFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFCZGtWbGZSUHo3QnE2TUxBOTc4Y0dDcndySzBHQjN6MlUvMQprZSt6T0VPRElpM0ZmV0xBWjlaRmJrckpmdGVQZ3l1Rm40ck5zd2JjR3RKZDFOSFFXTHN5TzI0dCtaaEpIWWIwCmJZRFg5WE90M3Y2MEp0TmVwblViWGRWMS9VRk5qV0x0TkFzTnFsNWhIeHZ5MnBGSEdaK1FFZ2h3TEpPOWFSakEKQ2p4MG1mYk9FQVBkM2xFNDRYeFhkZDNCUUVicm1zY1FOaW5McnVpY0twWkVmdnJPVGR4Nk5BV2gxQkdNa0xmRwplQXRBNzh4TnM0OFY0ZjBVNVZ0OUdLcGh5TXNLZitLYi9sS01oR2dlSVBWRGtBOFdxYUVYQ21leExMa3orcTRiCmhuRlhETDRjUzErd3BoQVY2M3FmWjh3c1h3bXJwNzYvVzdmcU55UktsN3FMdUM5SUJWMD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBOVVmSEV6eFhDZktFNTEwYlY3Uk14UU84SVlMTWFraVVEWndnUFZTSHdld0JzellBCnhrY0lHZUtPb3IyU1F6amFmd1pLTGlIdWFvaE5EYzJIL3FTV2VSOGNzZEk4TEVlRWlSQUt5RDBqNWxoMVVXUEoKOEkyU0poc09wTExsZjRLS1RJZFNib3FkTDZrWENwMW44MEd5WXN1UHh3WGFYWmIwYVBsVE5EZjZzVno5WC92Rwp4RFBIZTBsVkJwY0p2VWRLZkZ3b1hhT3oyOWV1ZVFWYld0djdhT0t6VFpua2lrRDBNeENkYldDWithYmRoRFFLCk8rY2xuMnlwQTZrbHR5S3lkYngxbk1wUy9peWFlZ1VRUjJDN1duaU1OdlhzZjRERDRaWTlrMFMrR2psOEJQci8KYnpXSnd0UHJWMzEzYjNUTUN0Q0dWYW5oM24vUHVMZ0lIVndFbVFJREFRQUJBb0lCQUZUQWNYd25ERmdta1YrMApYejlGMElUK3ptR3g1Vm9RTEFBcjQwUHQwbDdpWW8vKzUvT2JGYVNFRVE4UWU5cDRhWjhjbUVNcWZFd1pQcTYzClJ2ZG8vWWxxZzZxNTN3clp4MlRvd3lEL1owa3ZaWkl5N2RNTngrTWMxRWw2ZXl3OCtmYUpoNlVraGoyeXFvQ0QKZFNpcm1hempjNUdzWnhDUm1YQXdQbHk3dndiTFVxRHR6U0FIU2xtZmJsVjl0OFZUd1NKN1JxT2NQaGhaYTlqdwpuQThnc1dSbnhCZUxPVEFGRm5YQ2xEdmtvSHhlNWJYK1dKTVJaU3gveldPUUNtQzI0aHgyM0E2SEplQ3p2MzJHCmx5eDh1elJYd1hid0FNK1hzZ05IV2VuV1VxTXNGY0QrREdvSUZtN3o1NmFiOU1KcWNjRFdvckFnaE5xQXF5STAKUjcxcXkzVUNnWUVBL0RFd3FUVG5nZFY0QUhzWWtxcjZoeHpWVXpBQnlGcmdTMGNvNXpNc05CN0NzZFBLS0F0KwoyeGN4RmtNZkY4c3NRTTU4a1orbmxZWmN1emlkelN3WmhFcnRlaGxaQnFVN1U5dG9xQ0w0b0RKTm42WTdsemxQCkg4QTJDV0RrNFl1Q1RhV010ZmYxaFZWalpYMHRvKyt4R0ZscXlSNTVzMitGZmZ1dWNtK2hXenNDZ1lFQStQdmYKQmRnTlBpb3phWW45WjdnSkVHYjQxSWtBRHpLeVQrcHhXZFF1RWpxUlVobGFzeEJvWUhTNnV3UHg4Sy90WTk2eQpScGU2QnNGdFBiRTFMTDFDdkZXQjd2dXp1S3hEbGJlUFhVUVliclgwV0psQi9ycHZ6TkVzcjJneHpNZ1JqYlRSCnNxaEFVVGlzOXFYQ2VmNXBSWjBjcTJFTVNka0RHSlVKTTNFNEdqc0NnWUJqUStsbmNNOS9KMHNveFVzUzBBSDAKbE1EVEVaNWlBb011bmovWFlTa1JDdHFQckZGeUdiUkJBSXZ0dTFYTnc4Y1Rhek5WRG9ha01GTG56bzB1YVNGUwpGVHdNUjFYbmE3cENjNlpxSi9tODlJL2hPMGxSYU5sZ0lnUWpCT1NTY3B0RGZObzU5ZlBLRzZZWUdJR1NlWkkzCmgxcWs5ejNvQndtQVlVUjAvc09BYVFLQmdRQ1lDNDk5RFJ2Qks1b3J4L1YwWWlFKzMvTHlMeHRYTEpsUlRoU2MKUzRNNjVJTWJ4Sm5yb1locjVyeWxPZHFFSlpydEV2Q0JSV1IzZmFWTk9Dc0Z3Q25Cd3VITzQrd3pTUmNZbFhpNQo5cnlJMXhwNUJGWVZ6Um82MUQzYWUrRjFjWE91dW80WDhNRWVHR01mVjhnMElWVitDbHlZbDNJZW9xUk9YYXk1CnVsa05Rd0tCZ0Y0Qm9tdXhkbzA4YzlFK2lRUTJxYnk0bytBcmZ3WTBYMUNjOVVJVGpKOUJQYTZTZTV1ZDJHUy8KMlZYK3dNUzYvdEI0UGEyRmJrQ09mVDVVeEhVcWRCaUhTdFpTK0ZLRnBIS0RpRFNNNDlaSVFWckVBcW5Ucm1nNQpKQVFxRXlsalNWU0FxRnRCRWduZjc3TXVJT2QzTFlvZnQ2UGhtODEyd3l3azRTZmNhSjlNCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
root@master:~#
```

### /var/lib/kubelet/config.yaml

```
root@master:~# cat /var/lib/kubelet/config.yaml
address: 0.0.0.0
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: cgroupfs
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kind: KubeletConfiguration
kubeAPIBurst: 10
kubeAPIQPS: 5
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
port: 10250
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
root@master:~#
```


### systemctl cat kubelet

```
# /lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
# /etc/systemd/system/kubelet.service.d/20-kubelet-node-ip.conf
# Ansible managed
"kubelet.service" 30L, 1395C                                                                                                                1,1           Top
```
