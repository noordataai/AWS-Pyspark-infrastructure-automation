# 🏗️ Architecture Documentation

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Script Language & Technology Stack](#script-language--technology-stack)
- [Component Details](#component-details)
- [Data Flow](#data-flow)
- [Security Architecture](#security-architecture)
- [Error Handling Architecture](#error-handling-architecture)
- [Logging Architecture](#logging-architecture)
- [Scalability Considerations](#scalability-considerations)

---

## Overview

This document provides an in-depth technical architecture overview of the AWS PySpark Infrastructure Automation Scripts. These scripts implement Infrastructure as Code (IaC) principles using Bash scripting and AWS CLI.

---

## System Architecture

### High-Level Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        LOCAL ENVIRONMENT                              │
│                                                                        │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │                     Bash Scripts                            │     │
│  │                                                             │     │
│  │  ┌──────────────────────┐  ┌─────────────────────────┐   │     │
│  │  │ mission-deh-hof-     │  │ mission-deh-hof-        │   │     │
│  │  │ setup.sh             │  │ cleanup.sh              │   │     │
│  │  │                      │  │                         │   │     │
│  │  │ • Resource Creation  │  │ • Resource Deletion     │   │     │
│  │  │ • Data Generation    │  │ • Policy Detachment     │   │     │
│  │  │ • IAM Configuration  │  │ • Bucket Removal        │   │     │
│  │  │ • Error Rollback     │  │ • Role Cleanup          │   │     │
│  │  └──────────────────────┘  └─────────────────────────┘   │     │
│  │                                                             │     │
│  └──────────────────┬──────────────────────────────────────┘     │
│                     │                                              │
│                     │ AWS CLI Commands                             │
│                     │ (HTTPS/TLS)                                  │
│                     ▼                                              │
└─────────────────────┼──────────────────────────────────────────────┘
                      │
                      │ Authentication via IAM Credentials
                      │
┌─────────────────────▼──────────────────────────────────────────────┐
│                        AWS CLOUD                                    │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │                    AWS API Gateway                         │   │
│  │              (Validates & Routes Requests)                 │   │
│  └───────────────────────┬───────────────────────────────────┘   │
│                          │                                         │
│         ┌────────────────┼────────────────┐                       │
│         │                │                │                       │
│         ▼                ▼                ▼                       │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   AWS S3    │  │   AWS IAM    │  │   AWS STS    │           │
│  │             │  │              │  │              │           │
│  │ • Bucket    │  │ • Roles      │  │ • Account ID │           │
│  │ • Objects   │  │ • Policies   │  │ • Validation │           │
│  │ • Storage   │  │ • Trust Docs │  │              │           │
│  └─────────────┘  └──────────────┘  └──────────────┘           │
│         │                                                          │
│         │  Data Access via IAM Role                               │
│         ▼                                                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   AWS Glue                               │    │
│  │                                                           │    │
│  │  ┌─────────────────────────────────────────────┐        │    │
│  │  │         Glue Interactive Notebook            │        │    │
│  │  │                                              │        │    │
│  │  │  • PySpark Environment                       │        │    │
│  │  │  • Jupyter Interface                         │        │    │
│  │  │  • Uses: mission-deh-hof-glue-role          │        │    │
│  │  │  • Reads: s3://mission-deh-hof-*/raw/       │        │    │
│  │  └─────────────────────────────────────────────┘        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Script Language & Technology Stack

### Primary Language: **Bash (Shell Script)**

**Version:** Bash 4.0+  
**Shebang:** `#!/bin/bash`

### Why Bash?

| Reason | Explanation |
|--------|-------------|
| **Universal Availability** | Pre-installed on all Linux/Mac systems |
| **AWS CLI Integration** | Native support for AWS CLI commands |
| **Simple Automation** | Perfect for infrastructure automation |
| **No Dependencies** | No need for Python, Node.js, etc. |
| **Shell Integration** | Direct OS-level operations |

### Technology Stack

```
┌─────────────────────────────────────────────────────────┐
│                   Technology Layers                      │
└─────────────────────────────────────────────────────────┘

Layer 1: Scripting Language
  └─ Bash 4.0+
      └─ Features Used:
          • Arrays (CREATED_RESOURCES)
          • Heredocs (for CSV/JSON generation)
          • Trap handlers (error handling)
          • Functions (log, cleanup_on_failure)
          • Conditionals (if/else)
          • Regex matching (for resource tracking)

Layer 2: AWS CLI
  └─ AWS Command Line Interface 2.x
      └─ Services Used:
          • aws s3 (S3 operations)
          • aws iam (IAM management)
          • aws sts (Security Token Service)
      └─ Output Formats:
          • --output text (for parsing)
          • --no-cli-pager (for automation)

Layer 3: System Utilities
  └─ Standard Unix Tools
      └─ date (timestamps)
      └─ tee (logging)
      └─ cat (file creation)
      └─ rm (cleanup)
      └─ echo (output)

Layer 4: AWS Services
  └─ Amazon S3 (Storage)
  └─ AWS IAM (Identity & Access Management)
  └─ AWS Glue (Data Processing)
  └─ AWS STS (Temporary Security Credentials)
```

---

## Component Details

### 1. Setup Script (`mission-deh-hof-setup.sh`)

#### Internal Architecture

```
┌────────────────────────────────────────────────────────────┐
│              mission-deh-hof-setup.sh                      │
└────────────────────────────────────────────────────────────┘

[Initialization Phase]
  │
  ├─► Define Variables
  │     • LOG_FILE: Timestamped log filename
  │     • CREATED_RESOURCES: Array to track resources
  │
  ├─► Define Functions
  │     • log(): Logs messages with timestamps
  │     • cleanup_on_failure(): Rollback handler
  │
  └─► Set Error Trap
        • trap cleanup_on_failure ERR

[Discovery Phase]
  │
  └─► Fetch AWS Account ID
        • aws sts get-caller-identity
        • Store in ACCOUNT_ID variable
        • Used for unique naming

[Resource Creation Phase]
  │
  ├─► S3 Bucket Creation
  │     • Check if exists: aws s3 ls
  │     • Create: aws s3 mb
  │     • Track: CREATED_RESOURCES+=("S3_BUCKET")
  │
  ├─► Data Generation
  │     • Generate customers.csv (heredoc)
  │     • Generate orders.csv (heredoc)
  │     • Generate products.csv (heredoc)
  │
  ├─► Data Upload
  │     • Upload to s3://{bucket}/raw/
  │     • Clean up local files
  │
  ├─► IAM Role Creation
  │     • Create trust policy JSON
  │     • Check if role exists
  │     • Create role with trust policy
  │     • Track: CREATED_RESOURCES+=("IAM_ROLE")
  │
  └─► Policy Attachment
        • Attach AWSGlueServiceRole
        • Attach AmazonS3FullAccess
        • Create & attach PassRolePolicy
        • Clean up temporary files

[Completion Phase]
  │
  └─► Output Summary
        • List created resources
        • Provide next steps
        • Display log file location
```

#### Key Functions

**1. log() Function**
```bash
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
```
- **Purpose:** Unified logging with timestamps
- **Output:** Console + log file (via `tee`)
- **Format:** `[YYYY-MM-DD HH:MM:SS] Message`

**2. cleanup_on_failure() Function**
```bash
cleanup_on_failure() {
    # Check CREATED_RESOURCES array
    # Roll back only newly created resources
    # Avoid deleting pre-existing resources
}
```
- **Purpose:** Automatic rollback on errors
- **Trigger:** `trap cleanup_on_failure ERR`
- **Logic:** Only deletes resources created in current run

### 2. Cleanup Script (`mission-deh-hof-cleanup.sh`)

#### Internal Architecture

```
┌────────────────────────────────────────────────────────────┐
│            mission-deh-hof-cleanup.sh                      │
└────────────────────────────────────────────────────────────┘

[Initialization Phase]
  │
  ├─► Define Variables
  │     • LOG_FILE: Timestamped cleanup log
  │
  └─► Define Functions
        • log(): Same logging function

[Discovery Phase]
  │
  └─► Fetch AWS Account ID
        • Identify resources to delete

[Deletion Phase]
  │
  ├─► S3 Bucket Deletion
  │     • Check if exists: aws s3 ls
  │     • Delete: aws s3 rb --force
  │     • Handles missing gracefully
  │
  └─► IAM Role Deletion
        • Check if role exists
        • Detach AWSGlueServiceRole policy
        • Detach AmazonS3FullAccess policy
        • Delete inline PassRolePolicy (automatic)
        • Delete role: aws iam delete-role
        • Handles missing gracefully

[Completion Phase]
  │
  └─► Output Summary
        • Confirm cleanup completion
        • Note about manual Glue notebook deletion
        • Display log file location
```

---

## Data Flow

### Setup Script Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      SETUP DATA FLOW                             │
└─────────────────────────────────────────────────────────────────┘

Step 1: Identity Resolution
  User → AWS CLI → AWS STS → Account ID
                                 │
                                 ▼
Step 2: Resource Naming
  Account ID → Generate Unique Names
                 • mission-deh-hof-123456789012 (S3)
                 • mission-deh-hof-glue-role (IAM)
                                 │
                                 ▼
Step 3: Data Generation (Local)
  Bash Heredoc → customers.csv → Local Filesystem
  Bash Heredoc → orders.csv → Local Filesystem
  Bash Heredoc → products.csv → Local Filesystem
                                 │
                                 ▼
Step 4: Data Upload
  Local CSVs → AWS CLI → S3 Bucket
    ├─ customers.csv → s3://.../raw/customers.csv
    ├─ orders.csv → s3://.../raw/orders.csv
    └─ products.csv → s3://.../raw/products.csv
                                 │
                                 ▼
Step 5: IAM Configuration
  Trust Policy JSON → AWS IAM → Create Role
  AWS Managed Policies → AWS IAM → Attach to Role
  Inline Policy JSON → AWS IAM → Attach to Role
                                 │
                                 ▼
Step 6: Access Grant
  IAM Role → Trust Relationship → AWS Glue Service
                                 │
                                 ▼
Step 7: Ready for Use
  AWS Glue Notebook → Assume Role → Access S3 Data
```

### Cleanup Script Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLEANUP DATA FLOW                             │
└─────────────────────────────────────────────────────────────────┘

Step 1: Identity Resolution
  User → AWS CLI → AWS STS → Account ID
                                 │
                                 ▼
Step 2: Resource Identification
  Account ID → Construct Resource Names
                 • mission-deh-hof-123456789012 (S3)
                 • mission-deh-hof-glue-role (IAM)
                                 │
                                 ▼
Step 3: S3 Cleanup
  AWS CLI → List Objects → Delete All Objects
           → Delete Bucket
                                 │
                                 ▼
Step 4: IAM Cleanup
  AWS CLI → Detach Managed Policies
           → Delete Inline Policies (automatic)
           → Delete Role
                                 │
                                 ▼
Step 5: Verification
  AWS CLI → Verify Deletions → Confirm Complete
```

---

## Security Architecture

### Authentication & Authorization

```
┌─────────────────────────────────────────────────────────────┐
│                   Security Model                             │
└─────────────────────────────────────────────────────────────┘

Layer 1: User Authentication
  • AWS CLI configured with IAM user credentials
  • Access Key ID + Secret Access Key
  • Stored in ~/.aws/credentials

Layer 2: Authorization (Script Execution)
  • User's IAM permissions checked by AWS
  • Required permissions:
      ├─ s3:CreateBucket
      ├─ s3:DeleteBucket
      ├─ s3:PutObject
      ├─ iam:CreateRole
      ├─ iam:DeleteRole
      ├─ iam:AttachRolePolicy
      ├─ iam:DetachRolePolicy
      ├─ iam:PutRolePolicy
      └─ sts:GetCallerIdentity

Layer 3: Service Role (Runtime)
  • mission-deh-hof-glue-role
  • Trust relationship with glue.amazonaws.com
  • Assumed by AWS Glue notebooks
  • Policies:
      ├─ AWSGlueServiceRole (Glue operations)
      ├─ AmazonS3FullAccess (S3 read/write)
      └─ PassRolePolicy (Role passing)

Layer 4: Data Access
  • S3 bucket: Private by default
  • Access only via IAM role
  • No public access
```

### Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Explanation:**
- **Principal:** Only AWS Glue service can assume this role
- **Action:** `sts:AssumeRole` - Temporary credential generation
- **Effect:** Allow - Grants permission

### PassRole Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::{ACCOUNT_ID}:role/mission-deh-hof-glue-role"
    }
  ]
}
```

**Explanation:**
- **Purpose:** Allows Glue to pass the role to notebook instances
- **Scope:** Limited to specific role ARN
- **Security:** Prevents privilege escalation

---

## Error Handling Architecture

### Setup Script Error Handling

```
┌─────────────────────────────────────────────────────────────┐
│              Error Handling Mechanism                        │
└─────────────────────────────────────────────────────────────┘

[Normal Execution Path]
  Script Start
      │
      ├─► Execute Commands
      │     └─► Success → Continue
      │
      └─► Script End (exit 0)

[Error Path]
  Script Start
      │
      ├─► Execute Commands
      │     └─► ERROR → Trigger trap
      │               │
      │               ▼
      │        cleanup_on_failure()
      │               │
      │               ├─► Check CREATED_RESOURCES
      │               │
      │               ├─► If S3_BUCKET created:
      │               │     └─► Delete bucket (aws s3 rb --force)
      │               │
      │               ├─► If IAM_ROLE created:
      │               │     ├─► Detach policies
      │               │     └─► Delete role
      │               │
      │               ├─► Log rollback actions
      │               │
      │               └─► exit 1
      │
      └─► Script End (exit 1)

[Error Detection]
  • Set -e equivalent via trap
  • Catches:
      ├─ AWS CLI errors
      ├─ Permission denied
      ├─ Resource conflicts
      └─ Network failures
```

### Idempotency Design

**Idempotent Operations:**
```bash
# Check before create
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    log "⚠ S3 bucket already exists, skipping creation"
else
    aws s3 mb "s3://$BUCKET_NAME"
    CREATED_RESOURCES+=("S3_BUCKET")
fi
```

**Benefits:**
- Script can run multiple times
- No errors on re-runs
- Only creates missing resources
- Safe for automation

---

## Logging Architecture

### Log Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Logging System                            │
└─────────────────────────────────────────────────────────────┘

[Log File Creation]
  Filename: mission-deh-hof-{operation}-{timestamp}.log
  Location: Current directory
  Format: YYYYMMDD-HHMMSS

[Log Function]
  log() {
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
  }

  • Outputs to: STDOUT + LOG_FILE
  • Timestamp: Every message
  • Format: [YYYY-MM-DD HH:MM:SS] Message

[Log Levels (Informal)]
  • "Starting..." - Informational
  • "✓" - Success
  • "⚠" - Warning (non-fatal)
  • "ERROR:" - Critical error
  • "Fetching..." - In-progress

[Log Contents]
  ├─ Operation start/end markers (========)
  ├─ AWS Account ID
  ├─ Resource names
  ├─ API call results
  ├─ Error messages
  ├─ Rollback actions
  └─ Next steps instructions
```

### Sample Log Output

```log
[2026-08-02 14:30:00] ==========================================
[2026-08-02 14:30:00] Starting PySpark Skill Booster Setup
[2026-08-02 14:30:00] ==========================================
[2026-08-02 14:30:01] Fetching AWS Account ID...
[2026-08-02 14:30:02] Account ID: 123456789012
[2026-08-02 14:30:02] Creating S3 bucket: mission-deh-hof-123456789012
[2026-08-02 14:30:04] ✓ S3 bucket created successfully
[2026-08-02 14:30:04] Generating sample datasets...
[2026-08-02 14:30:05] ✓ Sample datasets generated
[2026-08-02 14:30:05] Uploading datasets to S3...
[2026-08-02 14:30:08] ✓ Datasets uploaded to s3://mission-deh-hof-123456789012/raw/
...
```

---

## Scalability Considerations

### Current Design Limitations

| Aspect | Current Limit | Reason |
|--------|---------------|--------|
| **Datasets** | 3 files, <1MB total | Hardcoded in script |
| **Region** | us-east-1 only | Single region specified |
| **Concurrency** | Sequential execution | No parallel operations |
| **Accounts** | One at a time | Account ID-based naming |

### Scaling Options

#### 1. Multi-Region Support

**Modification:**
```bash
# Current
--region us-east-1

# Enhanced
REGION=${AWS_REGION:-us-east-1}
--region $REGION
```

#### 2. Larger Datasets

**Modification:**
```bash
# Use AWS CLI to download from source
aws s3 cp s3://source-bucket/large-dataset.csv /tmp/
aws s3 cp /tmp/large-dataset.csv s3://$BUCKET_NAME/raw/
```

#### 3. Parallel Uploads

**Modification:**
```bash
# Current: Sequential
aws s3 cp customers.csv s3://$BUCKET_NAME/raw/
aws s3 cp orders.csv s3://$BUCKET_NAME/raw/

# Enhanced: Parallel
aws s3 cp customers.csv s3://$BUCKET_NAME/raw/ &
aws s3 cp orders.csv s3://$BUCKET_NAME/raw/ &
wait
```

#### 4. Multiple Environments

**Modification:**
```bash
# Add environment parameter
ENVIRONMENT=${1:-dev}
BUCKET_NAME="mission-deh-hof-$ENVIRONMENT-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-$ENVIRONMENT-glue-role"
```

**Usage:**
```bash
./mission-deh-hof-setup.sh dev
./mission-deh-hof-setup.sh staging
./mission-deh-hof-setup.sh prod
```

---

## Performance Metrics

### Typical Execution Times

| Operation | Duration | Network Dependent |
|-----------|----------|-------------------|
| **Account ID Fetch** | 1-2 seconds | Yes |
| **S3 Bucket Creation** | 2-3 seconds | Yes |
| **CSV Generation** | <1 second | No |
| **S3 Upload (3 files)** | 2-4 seconds | Yes |
| **IAM Role Creation** | 3-5 seconds | Yes |
| **Policy Attachment** | 2-3 seconds | Yes |
| **Total Setup Time** | **2-3 minutes** | Yes |
| **Total Cleanup Time** | **30-60 seconds** | Yes |

### Bottlenecks

1. **AWS API Latency** - Largest factor (network)
2. **IAM Propagation** - Role availability delay (~10 seconds)
3. **S3 Consistency** - Eventually consistent (rare issue)

---

## Deployment Architecture

### Where Scripts Run

```
┌─────────────────────────────────────────────────────────┐
│                   Deployment Options                     │
└─────────────────────────────────────────────────────────┘

Option 1: Local Machine
  • Developer workstation
  • Requires: Bash, AWS CLI
  • Use case: Learning, development

Option 2: CI/CD Pipeline
  • GitHub Actions, GitLab CI, Jenkins
  • Automated environment provisioning
  • Use case: Training automation

Option 3: EC2 Instance
  • AWS EC2 with IAM instance profile
  • No credential configuration needed
  • Use case: AWS-native automation

Option 4: AWS CloudShell
  • Browser-based shell in AWS Console
  • AWS CLI pre-installed
  • Use case: Quick testing

Option 5: Container
  • Docker with AWS CLI
  • Reproducible environment
  • Use case: Consistent execution
```

---

## Future Enhancements

### Potential Improvements

1. **Infrastructure as Code Migration**
   - Convert to Terraform or CloudFormation
   - Version control infrastructure
   - Drift detection

2. **Configuration File**
   - External config.yaml
   - Customizable parameters
   - No script editing needed

3. **Dry-Run Mode**
   ```bash
   ./mission-deh-hof-setup.sh --dry-run
   ```

4. **Resource Tagging**
   ```bash
   --tags Project=PySpark,Owner=DataTeam
   ```

5. **Email Notifications**
   - SNS topic integration
   - Success/failure alerts

6. **Cost Estimation**
   - Pre-run cost calculation
   - AWS Cost Calculator integration

7. **Multi-Account Support**
   - AWS Organizations integration
   - Cross-account role assumption

---

**Document Version:** 1.0  
**Last Updated:** August 2, 2026  
**Maintainer:** Noor Data AI
