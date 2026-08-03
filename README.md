# 🚀 AWS PySpark Infrastructure Automation Scripts

[![Language](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![AWS](https://img.shields.io/badge/AWS-Glue%20%7C%20S3%20%7C%20IAM-orange.svg)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Automated AWS infrastructure setup and teardown scripts for PySpark learning environments**

This repository contains robust Bash automation scripts designed to quickly provision and clean up AWS resources needed for PySpark data engineering practice and training.

---

## 📋 Table of Contents

- [Big Picture - What This Project Does](#-big-picture---what-this-project-does)
- [Main Motive](#-main-motive)
- [What the Scripts Do](#-what-the-scripts-do)
  - [Setup Script](#-setup-script)
  - [Cleanup Script](#-cleanup-script)
- [Side-by-Side Comparison](#-side-by-side-comparison)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [Sample Datasets](#-sample-datasets)
- [Logging](#-logging)
- [Error Handling](#-error-handling)
- [Cost Considerations](#-cost-considerations)
- [How to Create Similar Scripts](#-how-to-create-similar-scripts)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Big Picture - What This Project Does

This project provides **one-click infrastructure automation** for AWS PySpark learning environments. It eliminates the manual, error-prone process of:

- Creating S3 buckets
- Generating sample datasets
- Configuring IAM roles and permissions
- Setting up AWS Glue environments

**In just 2-3 minutes**, you can have a fully functional PySpark practice environment on AWS, complete with sample data for hands-on learning. When you're done, the cleanup script removes everything just as quickly, preventing unnecessary AWS costs.

**Perfect for:**
- 📚 Data engineering students
- 👨‍💻 PySpark learners
- 🏢 Training workshops
- 🧪 Quick proof-of-concepts
- 💼 Interview preparation

---

## 🌟 Main Motive

### **Why These Scripts Exist**

Learning PySpark and AWS Glue requires a properly configured environment with:
- Sample datasets for practice
- Correct IAM permissions
- S3 storage infrastructure
- AWS Glue roles

**The Problem:** Setting this up manually is:
- ⏰ Time-consuming (20-30 minutes)
- 🐛 Error-prone (permission issues, typos)
- 💸 Costly (forgotten resources rack up bills)
- 🔄 Repetitive (same steps every time)

**The Solution:** These scripts automate the entire process:
- ✅ **Setup in <3 minutes** - One command creates everything
- ✅ **Zero errors** - Automated, tested, reliable
- ✅ **Cost-safe** - Cleanup script removes all resources
- ✅ **Reproducible** - Same environment every time

---

## 🔧 What the Scripts Do

### 🟢 Setup Script

**File:** `mission-deh-hof-setup.sh`

**Purpose:** Creates a complete AWS PySpark learning environment

**What It Does Step-by-Step:**

1. **Fetches AWS Account ID**
   - Retrieves your unique AWS account identifier
   - Uses it to create unique resource names

2. **Creates S3 Bucket**
   - Bucket name: `mission-deh-hof-{ACCOUNT_ID}`
   - Region: `us-east-1`
   - Checks if already exists (idempotent)

3. **Generates Sample Datasets**
   - Creates 3 CSV files:
     - `customers.csv` - 10 customer records
     - `orders.csv` - 15 order records (with some NULL values)
     - `products.csv` - 6 product records (with NULL stock)
   - Realistic data for practicing:
     - Joins (customer-order-product)
     - NULL handling
     - Aggregations

4. **Uploads Data to S3**
   - Uploads all CSVs to `s3://{BUCKET_NAME}/raw/`
   - Cleans up local CSV files

5. **Creates IAM Role for AWS Glue**
   - Role name: `mission-deh-hof-glue-role`
   - Trust policy: Allows AWS Glue service to assume role

6. **Attaches IAM Policies**
   - `AWSGlueServiceRole` - Standard Glue permissions
   - `AmazonS3FullAccess` - Read/write S3 data
   - `PassRolePolicy` - Inline policy for role passing

7. **Logs Everything**
   - Timestamped log file: `mission-deh-hof-setup-YYYYMMDD-HHMMSS.log`
   - All operations logged with status (✓ success, ⚠ warning)

8. **Provides Next Steps**
   - Clear instructions for accessing AWS Glue Console
   - How to create and use Glue notebooks

**Output Example:**
```
==========================================
Setup completed successfully!
==========================================

Resources created:
  - S3 Bucket: mission-deh-hof-123456789012
  - IAM Role: mission-deh-hof-glue-role
  - Sample datasets uploaded to: s3://mission-deh-hof-123456789012/raw/

Next steps:
  1. Go to AWS Glue Console
  2. Navigate to ETL > Notebooks
  ...
```

---

### 🔴 Cleanup Script

**File:** `mission-deh-hof-cleanup.sh`

**Purpose:** Completely removes all AWS resources created by the setup script

**What It Does Step-by-Step:**

1. **Fetches AWS Account ID**
   - Identifies which resources to delete

2. **Deletes S3 Bucket**
   - Uses `--force` flag to delete all objects first
   - Then removes the bucket itself
   - Safely handles missing buckets

3. **Detaches IAM Policies**
   - Removes `AWSGlueServiceRole` policy
   - Removes `AmazonS3FullAccess` policy
   - Handles already-detached policies gracefully

4. **Deletes IAM Role**
   - Removes `mission-deh-hof-glue-role`
   - Safely handles missing roles

5. **Logs Everything**
   - Timestamped log file: `mission-deh-hof-cleanup-YYYYMMDD-HHMMSS.log`

**Output Example:**
```
==========================================
Cleanup completed successfully!
==========================================

Note: If you created Glue notebooks manually, delete them from the Glue Console
Log file: mission-deh-hof-cleanup-20260802-143022.log
```

---

## ⚖️ Side-by-Side Comparison

| Feature | Setup Script | Cleanup Script |
|---------|-------------|----------------|
| **Purpose** | Create resources | Delete resources |
| **S3 Bucket** | Creates bucket + uploads data | Deletes bucket + all contents |
| **IAM Role** | Creates role + attaches policies | Detaches policies + deletes role |
| **Sample Data** | Generates 3 CSV files | N/A - deleted with bucket |
| **Error Handling** | Rollback on failure | Graceful handling of missing resources |
| **Logging** | Detailed setup log | Detailed cleanup log |
| **Idempotency** | Can run multiple times safely | Can run multiple times safely |
| **Execution Time** | ~2-3 minutes | ~1 minute |
| **AWS Costs** | Creates billable resources | Prevents ongoing costs |

---

## 📦 Prerequisites

Before running these scripts, ensure you have:

### 1. **AWS CLI Installed**
```bash
# Check if AWS CLI is installed
aws --version

# If not installed, visit: https://aws.amazon.com/cli/
```

### 2. **AWS CLI Configured**
```bash
# Configure with your credentials
aws configure

# You'll need:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (use us-east-1)
# - Output format (json)
```

### 3. **Bash Shell**
- Linux/Mac: Built-in
- Windows: Use Git Bash or WSL (Windows Subsystem for Linux)

### 4. **IAM Permissions**
Your AWS user needs permissions to:
- Create/delete S3 buckets
- Create/delete IAM roles
- Attach/detach IAM policies
- Use STS (Security Token Service) to get account ID

### 5. **Make Scripts Executable**
```bash
chmod +x mission-deh-hof-setup.sh
chmod +x mission-deh-hof-cleanup.sh
```

---

## 🚀 Quick Start

### Step 1: Clone the Repository
```bash
git clone https://github.com/noordataai/aws-pyspark-infrastructure-automation.git
cd aws-pyspark-infrastructure-automation
```

### Step 2: Make Scripts Executable
```bash
chmod +x mission-deh-hof-setup.sh
chmod +x mission-deh-hof-cleanup.sh
```

### Step 3: Run Setup
```bash
./mission-deh-hof-setup.sh
```

**Expected output:**
```
[2026-08-02 14:30:00] ==========================================
[2026-08-02 14:30:00] Starting PySpark Skill Booster Setup
[2026-08-02 14:30:00] ==========================================
[2026-08-02 14:30:01] Fetching AWS Account ID...
[2026-08-02 14:30:02] Account ID: 123456789012
[2026-08-02 14:30:02] Creating S3 bucket: mission-deh-hof-123456789012
...
```

### Step 4: Use Your Environment
- Navigate to [AWS Glue Console](https://console.aws.amazon.com/glue/)
- Create a Glue Notebook
- Select the IAM role: `mission-deh-hof-glue-role`
- Start practicing PySpark!

### Step 5: Clean Up (When Done)
```bash
./mission-deh-hof-cleanup.sh
```

**Important:** Always run cleanup to avoid unnecessary AWS charges!

---

## 🏗️ Architecture

For detailed technical architecture, see [ARCHITECTURE.md](ARCHITECTURE.md)

**High-Level Overview:**

```
┌─────────────────────────────────────────────────────┐
│                  Local Machine                       │
│  ┌─────────────────────────────────────────────┐   │
│  │   mission-deh-hof-setup.sh                   │   │
│  │   mission-deh-hof-cleanup.sh                 │   │
│  └─────────────────────────────────────────────┘   │
│                      │                               │
│                      │ AWS CLI                       │
│                      ▼                               │
└──────────────────────┼───────────────────────────────┘
                       │
                       │
┌──────────────────────▼───────────────────────────────┐
│                   AWS Cloud                          │
│                                                       │
│  ┌─────────────────────────────────────────┐        │
│  │         S3 Bucket                        │        │
│  │  mission-deh-hof-{ACCOUNT_ID}           │        │
│  │                                          │        │
│  │  📁 raw/                                 │        │
│  │     ├── customers.csv                    │        │
│  │     ├── orders.csv                       │        │
│  │     └── products.csv                     │        │
│  └─────────────────────────────────────────┘        │
│                                                       │
│  ┌─────────────────────────────────────────┐        │
│  │      IAM Role                            │        │
│  │  mission-deh-hof-glue-role              │        │
│  │                                          │        │
│  │  Policies:                               │        │
│  │  • AWSGlueServiceRole                    │        │
│  │  • AmazonS3FullAccess                    │        │
│  │  • PassRolePolicy (inline)               │        │
│  └─────────────────────────────────────────┘        │
│                                                       │
│  ┌─────────────────────────────────────────┐        │
│  │      AWS Glue                            │        │
│  │  (Notebooks for PySpark)                 │        │
│  └─────────────────────────────────────────┘        │
└───────────────────────────────────────────────────────┘
```

---

## 📊 Sample Datasets

### customers.csv (10 records)
```csv
customer_id,name,email,country,signup_date
1,John Smith,john.smith@email.com,USA,2023-01-15
2,Maria Garcia,maria.garcia@email.com,Spain,2023-02-20
...
```

**Use Cases:**
- Customer segmentation by country
- Signup date analysis
- Customer lifetime value calculations

### orders.csv (15 records)
```csv
order_id,customer_id,product_id,quantity,order_date,amount
101,1,501,2,2023-04-01,199.98
108,NULL,501,2,2023-04-08,199.98  # Contains NULLs
...
```

**Use Cases:**
- Handling NULL customer_ids (data quality)
- Order aggregations by customer
- Revenue calculations
- Customer-order joins

### products.csv (6 records)
```csv
product_id,product_name,category,price,stock_quantity
501,Wireless Mouse,Electronics,99.99,150
506,Keyboard,Electronics,129.99,NULL  # Contains NULLs
...
```

**Use Cases:**
- Product catalog management
- Inventory analysis (NULL stock handling)
- Category-based aggregations
- Product-order joins

---

## 📝 Logging

Both scripts create timestamped log files for audit trails and debugging.

### Log File Naming
- Setup: `mission-deh-hof-setup-YYYYMMDD-HHMMSS.log`
- Cleanup: `mission-deh-hof-cleanup-YYYYMMDD-HHMMSS.log`

### Log Format
```
[YYYY-MM-DD HH:MM:SS] Log message
```

### Log Contents
- ✓ Success indicators
- ⚠ Warning indicators
- Resource names and IDs
- Error messages (if any)
- Rollback activities

### Viewing Logs
```bash
# View latest setup log
cat mission-deh-hof-setup-*.log | tail -n 50

# View latest cleanup log
cat mission-deh-hof-cleanup-*.log | tail -n 50
```

---

## 🛡️ Error Handling

### Setup Script Error Handling

**Automatic Rollback:**
If any error occurs during setup, the script automatically rolls back newly created resources:

1. **Trap ERR Signal**
   ```bash
   trap cleanup_on_failure ERR
   ```

2. **Track Created Resources**
   - Array: `CREATED_RESOURCES[]`
   - Tracks: S3_BUCKET, IAM_ROLE

3. **Rollback Logic**
   - Deletes S3 bucket (if created)
   - Detaches IAM policies (if attached)
   - Deletes IAM role (if created)
   - Logs all rollback actions

**Example Rollback Output:**
```
[2026-08-02 14:32:15] ERROR: Unexpected error occurred. Rolling back newly created resources...
[2026-08-02 14:32:16] Deleting S3 bucket: mission-deh-hof-123456789012
[2026-08-02 14:32:18] Detaching policies from role: mission-deh-hof-glue-role
[2026-08-02 14:32:19] Deleting IAM role: mission-deh-hof-glue-role
[2026-08-02 14:32:20] Rollback completed. Check log file: mission-deh-hof-setup-20260802-143200.log
```

### Cleanup Script Error Handling

**Graceful Degradation:**
- Checks if resources exist before deletion
- Continues even if resources are missing
- Logs warnings for missing resources

---

## 💰 Cost Considerations

### AWS Costs Breakdown

| Resource | Cost | Notes |
|----------|------|-------|
| **S3 Storage** | ~$0.023 per GB/month | Sample data is <1MB (negligible) |
| **S3 Requests** | ~$0.0004 per 1000 requests | Setup makes ~3 PUT requests |
| **IAM Role** | FREE | No charges for IAM roles |
| **AWS Glue Notebook** | ~$0.44 per hour | Only charged when notebook is running |

**Total Cost for Learning Session:**
- Setup/Cleanup: < $0.01
- 1-hour Glue notebook: ~$0.44
- **Total: < $0.50 per session**

### Cost-Saving Tips

1. **Always run cleanup script** when done
2. **Stop Glue notebooks** when not in use
3. **Delete Glue notebooks** you no longer need
4. **Set AWS billing alerts** for unexpected charges

---

## 🎓 How to Create Similar Scripts

### Prompt Template for Future Scripts

If you want to create similar AWS automation scripts, use this prompt:

```
Create two bash scripts for AWS resource automation:

1. SETUP SCRIPT that:
   - Creates an S3 bucket with a unique name using AWS account ID
   - Generates sample CSV datasets with the following structure:
     * [Describe your data structure]
   - Uploads files to S3 in specific folder structure
   - Creates an IAM role for [AWS service name, e.g., AWS Glue, Lambda]
   - Attaches the following IAM policies:
     * [List specific AWS managed policies]
     * [List inline policies with their JSON]
   - Implements error handling with automatic rollback using trap
   - Logs all operations with timestamps to a file
   - Checks if resources already exist before creating (idempotent)
   - Provides clear next steps after completion

2. CLEANUP SCRIPT that:
   - Fetches AWS account ID to identify resources
   - Deletes the S3 bucket and all its contents using --force
   - Detaches all IAM policies from the role
   - Deletes the IAM role
   - Logs all cleanup operations with timestamps
   - Handles missing resources gracefully (no errors)
   - Provides confirmation message after completion

REQUIREMENTS:
   - Use proper bash error handling (trap ERR)
   - Create timestamped log files for audit trail
   - Check if resources already exist before creating
   - Provide clear success (✓) and warning (⚠) messages
   - Include detailed inline comments
   - Use AWS CLI commands with --no-cli-pager flag
   - Make scripts idempotent (safe to run multiple times)
   - Include resource name variables at the top for easy customization

OPTIONAL FEATURES:
   - Add resource tagging for cost tracking
   - Support multiple AWS regions
   - Add dry-run mode (show what would be created without creating)
   - Add email notifications on completion
```

### Customization Points

When adapting these scripts for your needs, modify:

1. **Resource Names**
   ```bash
   BUCKET_NAME="your-project-name-$ACCOUNT_ID"
   ROLE_NAME="your-project-glue-role"
   ```

2. **Sample Data Structure**
   - Change CSV headers and data
   - Add more datasets
   - Use JSON or Parquet instead of CSV

3. **IAM Policies**
   - Add/remove managed policies
   - Modify inline policies
   - Change trust relationships

4. **AWS Region**
   ```bash
   --region us-west-2  # Change from us-east-1
   ```

5. **S3 Folder Structure**
   ```bash
   s3://$BUCKET_NAME/raw/          # Current
   s3://$BUCKET_NAME/bronze/       # Alternative
   ```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "AWS CLI not found"
**Error:**
```
bash: aws: command not found
```

**Solution:**
```bash
# Install AWS CLI
# For Linux/Mac:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# For Windows: Download from https://aws.amazon.com/cli/
```

#### 2. "Unable to locate credentials"
**Error:**
```
Unable to locate credentials. You can configure credentials by running "aws configure".
```

**Solution:**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter region: us-east-1
# Enter output format: json
```

#### 3. "Access Denied" Errors
**Error:**
```
An error occurred (AccessDenied) when calling the CreateBucket operation
```

**Solution:**
- Check your IAM user permissions
- Ensure you have `s3:CreateBucket`, `iam:CreateRole`, etc.
- Contact your AWS administrator

#### 4. "Bucket Already Exists"
**Error:**
```
A conflicting conditional operation is currently in progress
```

**Solution:**
- The setup script handles this automatically
- If issue persists, run cleanup script first:
  ```bash
  ./mission-deh-hof-cleanup.sh
  ./mission-deh-hof-setup.sh
  ```

#### 5. "Permission denied" on Script
**Error:**
```
bash: ./mission-deh-hof-setup.sh: Permission denied
```

**Solution:**
```bash
chmod +x mission-deh-hof-setup.sh
chmod +x mission-deh-hof-cleanup.sh
```

### Getting Help

If you encounter issues:

1. **Check the log files** - They contain detailed error messages
2. **Verify AWS CLI** - Run `aws sts get-caller-identity`
3. **Check IAM permissions** - Ensure your user has required access
4. **Review AWS Console** - Manually verify resource state
5. **Open an issue** - [Create an issue](https://github.com/noordataai/aws-pyspark-infrastructure-automation/issues) on GitHub

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs
- Use the [issue tracker](https://github.com/noordataai/aws-pyspark-infrastructure-automation/issues)
- Include log files and error messages
- Describe steps to reproduce

### Suggesting Features
- Open a feature request issue
- Describe the use case
- Explain why it would be useful

### Submitting Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines
- Follow existing code style
- Add comments for complex logic
- Update documentation for new features
- Test on multiple AWS accounts
- Ensure scripts remain idempotent

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**TL;DR:** You can freely use, modify, and distribute these scripts.

---

## 🌟 Star This Repository

If you find this project helpful, please consider giving it a ⭐ on GitHub!

---

## 📧 Contact

**Maintainer:** Noor Data AI  
**GitHub:** [@noordataai](https://github.com/noordataai)  
**Repository:** [aws-pyspark-infrastructure-automation](https://github.com/noordataai/aws-pyspark-infrastructure-automation)

---

## 🙏 Acknowledgments

- AWS Glue team for comprehensive documentation
- PySpark community for inspiration
- All contributors and users of this project

---

## 📚 Additional Resources

- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

---

**Happy Learning! 🎉**

*Last Updated: August 2, 2026*
