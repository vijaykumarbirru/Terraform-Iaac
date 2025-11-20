Comprehensive Project Documentation: Deployment Process Summary

1. Overview
   
This document outlines the architecture for a highly available, secure, and scalable cloud application deployed across two primary Virtual Private Clouds (VPCs) within the us-west-2 (Oregon) region. The architecture uses a layered approach, separating public-facing services (Frontend/Gateway) from the core business logic and data services (Backend), ensuring minimal exposure for sensitive components.
Key Technology Stack:
•	Infrastructure: AWS (Amazon Web Services)
•	Containerization: Amazon EKS (Elastic Kubernetes Service)
•	Application: WebBrowser Client connecting to a containerized Frontend (likely Nginx) which communicates with a Backend (likely Spring Boot).

3. Component Breakdown
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
<img width="468" height="642" alt="image" src="https://github.com/user-attachments/assets/24669c0c-898f-4cdb-83d7-ff4deac8b77a" />

