Comprehensive Project Documentation: Deployment Process Summary

1. Overview
This document outlines the architecture for a highly available, secure, and scalable cloud application deployed across two primary Virtual Private Clouds (VPCs) within the us-west-2 (Oregon) region. The architecture uses a layered approach, separating public-facing services (Frontend/Gateway) from the core business logic and data services (Backend), ensuring minimal exposure for sensitive components.
Key Technology Stack:
•	Infrastructure: AWS (Amazon Web Services)
•	Containerization: Amazon EKS (Elastic Kubernetes Service)
•	Application: WebBrowser Client connecting to a containerized Frontend (likely Nginx) which communicates with a Backend (likely Spring Boot).

2. Component Breakdown
The architecture is divided into two main environments, connected via VPC Peering.
A. Gateway VPC (Public Facing)
Component	Service Type	Role and Function
WebBrowser Client	Actor/User	The end-user accessing the application.
ALB Public	Application Load Balancer	The entry point for all external traffic. It accepts HTTP(S) requests from the internet and routes them to the Frontend Pods.
EKS Cluster (Private)	Kubernetes Service	Hosts the Frontend Pods. The worker nodes and pods reside entirely in private subnets for enhanced security.
Frontend Pod	Application Component	The user-facing application layer (e.g., UI, proxy, API Gateway). It initiates all internal calls to the Backend service.
IGW	Internet Gateway	Allows the ALB Public and the public subnets to communicate with the internet.
NAT	Network Address Translation	Resides in a Public Subnet. Allows resources in the Private subnet (like EKS worker nodes) to initiate outbound connections (e.g., for updates or external APIs) without being directly exposed to the internet.
Bastion Host	EC2 Instance	A security-hardened server placed in a Public Subnet, used for secure administrative access (SSH/RDP) to the private resources within the Gateway VPC.
VPC Endpoint (Interface)	Interface Endpoint (Powered by AWS PrivateLink)	Allows the Frontend Pods (in the Gateway VPC) to connect privately to the VPC Endpoint Service (hosted in the Backend VPC) without traversing the public internet. It functions as a network interface with private IP addresses in your subnet, serving as the entry point for traffic destined for the service.

B. Backend VPC (Internal Services)
Component	Service Type	Role and Function
Spring Boot Pod	Application Component	The core business logic and API service. It runs on the Backend EKS cluster and is only reachable internally.
ALB Internal	Application Load Balancer	Receives traffic only from the Gateway VPC and distributes it to the Spring Boot Pods.
NLB	Network Load Balancer	Used for high-performance, layer-4 (TCP/UDP) routing. Serves as a target for the VPC Endpoint Service, directing traffic to the ALB Internal.
IGW	Internet Gateway	Allows public resources in the Backend VPC to communicate with the internet (though primary app traffic is internal).
NAT	Network Address Translation	Allows Backend Private Subnet resources (EKS worker nodes) to access the internet for updates or external APIs.
Bastion Host	EC2 Instance	Provides secure administrative access to the private resources within the Backend VPC.
EKS Cluster (Private)	Kubernetes Service	Hosts the Frontend Pods. The worker nodes and pods reside entirely in private subnets for enhanced security.
NAT Gateway	Network Address Translation	Manages outbound internet traffic from private subnets in the VPC (e.g., for EKS Pods/Worker Nodes to download patches or contact external public APIs). It is placed in a Public Subnet
VPC Endpoint Service	AWS PrivateLink Service (Provider)	Exposes the Backend service (via the NLB) privately to other AWS accounts or VPCs (Consumers). It allows the Frontend Pods to connect to the Backend Pods using private IP addresses.

3. Network Flow and Inter-VPC Communication
The architecture employs VPC Endpoints and VPC Peering to maintain a highly secure and private flow for internal communication.
Request Flow (External to Internal)
1.	Client Access: The WebBrowser Client sends a request to the public endpoint address of the ALB Public.
2.	Frontend Routing: The ALB Public forwards the request to the Frontend Pod within the Gateway EKS cluster.
3.	Internal Call Initiation: The Frontend Pod needs to call the Backend service (Spring Boot Pod). This happens through the secure, private connection mechanism:
o	The Frontend service is configured to target the VPC Endpoint Interface.
o	This interface uses the AWS network fabric to connect privately to the VPC Endpoint Service hosted in the Backend VPC.
4.	Backend Routing: The traffic entering the Backend VPC via the VPC Endpoint Service is routed to the NLB.
5.	Final Delivery: The NLB forwards the request to the ALB Internal, which finally distributes the load across the various Spring Boot Pods.
Administrative Access
•	Bastion Host & VPC Peering: Both the Gateway and Backend VPCs have their own Bastion Host for administrative access. Crucially, the Bastion Host in the Gateway VPC is connected via VPC Peering to the Backend VPC. This allows administrators to securely jump from the Gateway VPC's Bastion Host to the Backend VPC's Bastion Host, and from there access private resources like the EKS worker nodes in the private subnets of both VPCs.
4. Security and Isolation Principles
1.	Defense in Depth: The application uses multiple layers of load balancers (ALB Public -> NLB -> ALB Internal) and network segmentation to ensure the core business logic is heavily protected.
2.	Private by Default: All critical application components (EKS Clusters and application Pods) are deployed exclusively in Private Subnets. They have no direct public IP address or exposure.
3.	Controlled Outbound Traffic: Resources in private subnets can only access the internet (if required) via the NAT gateway, ensuring all outbound traffic originates from a known, shared IP address.
4.	Zero Public Exposure for Backend: The Backend VPC, the ALB Internal, and the Spring Boot Pods are not accessible from the Internet Gateway (IGW) and can only be reached through the private VPC Endpoint Service connection originating from the Gateway VPC.
5.	Secure Administration: Access to the private network segments is strictly controlled through the security-hardened Bastion Hosts, minimizing the attack surface.




Infra and Application Deployment:
1. Core Project Details
Detail	Value
Deployment Region	us-west-2 (Oregon)
End User Access URL	http://k8s-app-albingre-041fae0a32-6974032.us-west-2.elb.amazonaws.com/
IaC Repository	https://github.com/vijaykumarbirru/Terraform-Iaac
Frontend Repository	https://github.com/vijaykumarbirru/gateway-proxyapp
Backend Repository	https://github.com/vijaykumarbirru/backend-spring-boot

2. Infrastructure Deployment (IaC) Process
The entire AWS infrastructure—including two separate VPCs (Gateway and Backend), EKS clusters, load balancers, and private network connections (VPC Endpoints, VPC Peering)—is provisioned and managed by Terraform.
2.1 Modular Terraform Approach
•	Tooling: Terraform
•	Methodology: The infrastructure code is structured using a modular approach. This means that complex resources (like a VPC or an EKS cluster) are defined in reusable modules, rather than a single large configuration file.
o	Justification for Modularity: Ensures consistency, promotes reusability across different stages/environments (if expanded), and simplifies troubleshooting and maintenance.
•	Automation: GitHub Actions
•	Process Flow:
1.	A developer makes a change and pushes to the main branch of the Terraform-Iaac repository.
2.	The GitHub Actions workflow triggers.
3.	The workflow executes terraform plan (showing proposed changes) and then terraform apply, which automatically provisions or updates all necessary AWS resources in us-west-2.
3. Application Deployment (CI/CD) Process
The Frontend and Backend applications are containerized and deployed to their respective EKS clusters using Helm Charts, leveraging a dedicated Runner within the AWS network for secure access.
3.1 CI/CD Pipeline Structure
Both application pipelines (gateway-proxyapp and backend-spring-boot) follow a consistent two-phase workflow:
Phase 1: Continuous Integration (CI) - Build & Containerize
•	Trigger: Push to the main branch of either application repository.
•	Key Steps:
1.	Compile the application (e.g., build the Spring Boot JAR or frontend bundle).
2.	Create a Docker image containing the compiled application.
3.	Tag the Docker image (typically with a unique commit SHA or version number).
4.	Push the tagged image to a secure container registry (e.g., AWS ECR).
Phase 2: Continuous Deployment (CD) - Deploy to EKS
•	Tooling: Helm Charts
•	Runner Requirement: Deployment is handled by a GitHub Actions Runner (often a self-hosted EC2 instance or Fargate container). This Runner is deployed within the AWS network (with appropriate IAM roles) to ensure it has secure, private access to communicate with the EKS cluster API servers and deploy to the private worker nodes.
•	Key Steps:
1.	The Runner authenticates with the target EKS cluster (Gateway or Backend).
2.	The Runner executes the Helm command: helm upgrade --install [chart-name] --set image.tag=[new-tag].
3.	Justification for Helm: Helm packages the application and its Kubernetes manifests (Deployment, Service, Ingress/ALB) into a single chart, providing version control, easy configuration templating, and reliable zero-downtime rolling updates and rollbacks.
4.	Kubernetes automatically pulls the new container image from ECR and performs the rolling update of the target Pods (Frontend Pods or Spring Boot Pods).



Final output:
http://k8s-app-albingre-041fae0a32-6974032.us-west-2.elb.amazonaws.com/
<img width="468" height="597" alt="image" src="https://github.com/user-attachments/assets/3254a40c-6408-40a4-bcb0-2ccbf6245909" />

