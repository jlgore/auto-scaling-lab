# Auto Scaling Module with Simple Scaling Policy

This project contains a Terraform module for setting up an Auto Scaling Group (ASG) with a simple scaling policy on AWS. The main branch implements a simple scaling policy, while other branches may implement different scaling strategies.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v0.12+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Git](https://git-scm.com/downloads)

## Deployment Steps

1. Clone the repository:
   ```
   git clone https://github.com/jlgore/auto-scaling-lab.git
   cd auto-scaling-lab
   ```

2. Switch to the main branch (if not already on it):
   ```
   git checkout main
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

## Configuration Details

The main branch uses a simple scaling policy with the following default configuration:

- Minimum size: 1 instance
- Maximum size: 3 instances
- Desired capacity: 2 instances
- Scaling adjustment: 1 instance at a time
- Cooldown period: 300 seconds (5 minutes)

You can modify these values in the `main.tf` file or by passing variables when calling the module.

## Cleaning Up

To destroy the created resources:

```
terraform destroy
```

Confirm the destruction by typing `yes` when prompted.

## Switching to Other Scaling Policies

To use a different scaling policy, check out the corresponding branch. For example:

```
git checkout target-tracking-policy
```

Then follow the deployment steps above.

## Support

If you encounter any issues or have questions, please file an issue in the GitHub repository.
