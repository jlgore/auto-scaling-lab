# Auto Scaling Module with Simple Scaling Policy

This project contains a Terraform module for setting up an Auto Scaling Group (ASG) with a simple scaling policy on AWS. The main branch implements a simple scaling policy, while other branches may implement different scaling strategies.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v0.12+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Git](https://git-scm.com/downloads)

### Installing Terraform on Amazon Linux 2023

- Install Yum Utils.

`sudo yum install -y yum-utils`

- Add the Hashicorp Repo

`sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`

- Install Terraform

`sudo yum -y install terraform`


## Deployment Steps

1. Clone the repository:
   ```
   git clone https://github.com/jlgore/auto-scaling-lab.git
   cd auto-scaling-lab
   ```

2. Choose the desired scaling policy by checking out the appropriate branch:
   ```
   git checkout main  # for simple scaling policy
   # or
   git checkout target-tracking-policy
   # or
   git checkout step-scaling-policy
   ```

3. Initialize Terraform:
   ```
   terraform init
   ```

4. Review and modify the `terraform.tfvars` file to set your desired values. At minimum, you should specify:
   - `vpc_id`
   - `subnet_ids`
   - `target_group_arns`
   - `launch_template_id`

5. Review the planned changes:
   ```
   terraform plan
   ```

6. Apply the Terraform configuration:
   ```
   terraform apply
   ```

7. Confirm the changes by typing `yes` when prompted.

## Scaling Policies Explained

This project offers three types of scaling policies. Each policy is implemented in a separate branch:

### 1. Simple Scaling Policy (main branch)

Simple scaling adjusts the number of EC2 instances in the Auto Scaling group based on a single scaling adjustment.

- **Use case**: When you have predictable workload patterns or want to maintain a specific number of instances.
- **Pros**: Easy to understand and implement.
- **Cons**: May lead to over-provisioning or under-provisioning as it doesn't consider the magnitude of the alarm breach.

Configuration example:
```hcl
scaling_policy = "simple"
simple_scaling_adjustment = 1
simple_scaling_cooldown = 300
```

### 2. Step Scaling Policy (step-scaling-policy branch)

Step scaling policies increase or decrease the current capacity of the Auto Scaling group based on a set of scaling adjustments, known as step adjustments.

- **Use case**: When you want to scale based on the magnitude of the alarm breach.
- **Pros**: More granular control over scaling actions.
- **Cons**: Can be complex to set up and tune properly.

Configuration example:
```hcl
scaling_policy = "step"
step_scaling_adjustments = [
  {
    scaling_adjustment = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
  },
  {
    scaling_adjustment = 2
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
  },
  {
    scaling_adjustment = 3
    metric_interval_lower_bound = 20
  }
]
```

### 3. Target Tracking Scaling Policy (target-tracking-policy branch)

Target tracking scaling policies automatically adjust the number of EC2 instances in your Auto Scaling group to maintain a specified metric at a target value.

- **Use case**: When you want to maintain a specific metric (e.g., average CPU utilization) at a target value.
- **Pros**: Simplifies scaling by letting AWS manage the scaling process based on a target metric.
- **Cons**: May not be suitable for applications with wildly fluctuating metrics.

Configuration example:
```hcl
scaling_policy = "target_tracking"
target_tracking_metric = "ASGAverageCPUUtilization"
target_tracking_target = 50
```

## Choosing the Right Policy

- Use **Simple Scaling** for basic needs and predictable workloads.
- Use **Step Scaling** for more granular control over scaling actions based on metric values.
- Use **Target Tracking** for maintaining a specific metric at a target value with minimal configuration.

## Cleaning Up

To destroy the created resources:

```
terraform destroy
```

Confirm the destruction by typing `yes` when prompted.

## Support

If you encounter any issues or have questions, please file an issue in the GitHub repository.