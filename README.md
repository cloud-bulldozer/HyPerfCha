# HyPerfCha
Tools which run Performance and Chaos test on large Scale Managed Hypershift clusters on public cloud. Focuses on benchmarking HostedControlPlanes and Management Control Planes at high workload and turbulence. 

It executes a series of jobs in order to stress the environment by scaling them to max capacity and it simulates a percentile of real world workload/traffic/outages on them. It utilizes three key tools and an observability stack for reporting and monitoring, 

## HCP Burner: 
It is a cluster orchestrator, spins up a specified number of clusters simultaneously, in this case managed ROSA HCP clusters and prepares them for workload execution. Additionally, it calculates various metrics such as cluster installation & destruction times as well as collects Management Clusters usage metrics.
More details https://github.com/cloud-bulldozer/hcp-burner 

## Kube-Burner:
It is a workload orchestrator, loads up a cluster with Openshift resources at large scale and takes care of reporting, alerting as well as collecting and indexing metrics. In this case, we use this to run a percentile of workload on all ROSA HCP concurrently to stress all control plane components.
More details https://github.com/kube-burner/kube-burner

## Krkn: 
This is a Chaos and resiliency testing tool for Kubernetes. Also called as Kraken, it injects deliberate failures into Kubernetes clusters to check if it is resilient to turbulent conditions.
More details https://github.com/krkn-chaos/krkn

Environment under stress during this test,
HCP - ROSA HCP
MC - OSD on AWS 

![hyperfcha](https://github.com/user-attachments/assets/eb71c501-6c7b-4c4b-93e8-9f32d6651dfe)

