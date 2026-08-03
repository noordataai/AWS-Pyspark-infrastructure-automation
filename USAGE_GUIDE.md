# 📖 Detailed Usage Guide

## Table of Contents
- [Getting Started](#getting-started)
- [Step-by-Step Tutorial](#step-by-step-tutorial)
- [Common Use Cases](#common-use-cases)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)
- [FAQ](#faq)

---

## Getting Started

### Prerequisites Check

Before running the scripts, verify all prerequisites:

```bash
# 1. Check Bash version (need 4.0+)
bash --version

# 2. Check AWS CLI installation
aws --version

# 3. Check AWS credentials are configured
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/your-username"
# }

# 4. Check required IAM permissions
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::YOUR_ACCOUNT_ID:user/YOUR_USERNAME \
    --action-names s3:CreateBucket iam:CreateRole \
    --no-cli-pager
```

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/noordataai/aws-pyspark-infrastructure-automation.git
cd aws-pyspark-infrastructure-automation

# 2. Make scripts executable
chmod +x mission-deh-hof-setup.sh
chmod +x mission-deh-hof-cleanup.sh

# 3. Verify scripts are executable
ls -l *.sh
# Should show: -rwxr-xr-x
```

---

## Step-by-Step Tutorial

### Tutorial 1: First-Time Setup

**Goal:** Set up your first PySpark environment

**Time Required:** 5-10 minutes

#### Step 1: Understand What Will Be Created

The setup script will create:
- 1 S3 bucket: `mission-deh-hof-{YOUR_ACCOUNT_ID}`
- 3 CSV files uploaded to S3
- 1 IAM role: `mission-deh-hof-glue-role`
- 3 IAM policies attached to the role

**Estimated AWS Cost:** < $0.01

#### Step 2: Run the Setup Script

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
[2026-08-02 14:30:04] ✓ S3 bucket created successfully
[2026-08-02 14:30:04] Generating sample datasets...
[2026-08-02 14:30:05] ✓ Sample datasets generated
[2026-08-02 14:30:05] Uploading datasets to S3...
[2026-08-02 14:30:08] ✓ Datasets uploaded to s3://mission-deh-hof-123456789012/raw/
[2026-08-02 14:30:08] Creating IAM trust policy...
[2026-08-02 14:30:09] Creating IAM role: mission-deh-hof-glue-role
[2026-08-02 14:30:11] ✓ IAM role created
[2026-08-02 14:30:11] Attaching policies to IAM role...
[2026-08-02 14:30:14] ✓ Policies attached
[2026-08-02 14:30:14] Adding PassRole inline policy...
[2026-08-02 14:30:16] ✓ PassRole policy added
[2026-08-02 14:30:16] ==========================================
[2026-08-02 14:30:16] Setup completed successfully!
[2026-08-02 14:30:16] ==========================================
```

#### Step 3: Verify Resources in AWS Console

**Verify S3 Bucket:**
```bash
aws s3 ls mission-deh-hof-$(aws sts get-caller-identity --query Account --output text)/raw/

# Expected output:
# 2026-08-02 14:30:08       1234 customers.csv
# 2026-08-02 14:30:08       1567 orders.csv
# 2026-08-02 14:30:08        890 products.csv
```

**Verify IAM Role:**
```bash
aws iam get-role --role-name mission-deh-hof-glue-role

# Expected output: JSON with role details
```

#### Step 4: Access AWS Glue Console

1. Open your browser and go to: https://console.aws.amazon.com/glue/
2. Sign in with your AWS credentials
3. Navigate to **ETL → Notebooks** (or **Glue Studio → Notebooks**)

#### Step 5: Create a Glue Notebook

1. Click **"Create notebook"**
2. **Notebook name:** `pyspark-practice`
3. **IAM Role:** Select `mission-deh-hof-glue-role` from dropdown
4. **Kernel:** Choose **Spark** or **PySpark**
5. Click **"Create notebook"**

**Wait time:** 2-3 minutes for notebook to start

#### Step 6: Write Your First PySpark Code

Once the notebook starts, create a new cell and paste:

```python
# Read customers data from S3
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Practice").getOrCreate()

# Replace ACCOUNT_ID with your AWS account ID
BUCKET_NAME = "mission-deh-hof-ACCOUNT_ID"

# Read data
customers_df = spark.read.csv(
    f"s3://{BUCKET_NAME}/raw/customers.csv",
    header=True,
    inferSchema=True
)

# Display data
customers_df.show()

# Expected output:
# +-----------+---------------+-------------------------+---------+-----------+
# |customer_id|name           |email                    |country  |signup_date|
# +-----------+---------------+-------------------------+---------+-----------+
# |1          |John Smith     |john.smith@email.com     |USA      |2023-01-15 |
# |2          |Maria Garcia   |maria.garcia@email.com   |Spain    |2023-02-20 |
# ...
```

#### Step 7: Practice PySpark Operations

Try these exercises:

**Count records:**
```python
print(f"Total customers: {customers_df.count()}")
```

**Filter by country:**
```python
usa_customers = customers_df.filter(customers_df.country == "USA")
usa_customers.show()
```

**Group and aggregate:**
```python
customers_by_country = customers_df.groupBy("country").count()
customers_by_country.show()
```

#### Step 8: Clean Up When Done

**Important:** Always clean up to avoid AWS charges!

```bash
# Stop and delete your Glue notebook first (in AWS Console)

# Then run cleanup script
./mission-deh-hof-cleanup.sh
```

**Expected output:**
```
[2026-08-02 16:30:00] ==========================================
[2026-08-02 16:30:00] Starting PySpark Skill Booster Cleanup
[2026-08-02 16:30:00] ==========================================
[2026-08-02 16:30:01] Fetching AWS Account ID...
[2026-08-02 16:30:02] Account ID: 123456789012
[2026-08-02 16:30:02] Deleting S3 bucket: mission-deh-hof-123456789012
[2026-08-02 16:30:05] ✓ S3 bucket deleted
[2026-08-02 16:30:05] Detaching policies from role: mission-deh-hof-glue-role
[2026-08-02 16:30:08] Deleting IAM role: mission-deh-hof-glue-role
[2026-08-02 16:30:09] ✓ IAM role deleted
[2026-08-02 16:30:09] ==========================================
[2026-08-02 16:30:09] Cleanup completed successfully!
[2026-08-02 16:30:09] ==========================================
```

#### Step 9: Verify Complete Cleanup

```bash
# Check S3 bucket (should not exist)
aws s3 ls mission-deh-hof-$(aws sts get-caller-identity --query Account --output text)
# Expected: An error (bucket not found)

# Check IAM role (should not exist)
aws iam get-role --role-name mission-deh-hof-glue-role
# Expected: An error (role not found)
```

---

## Common Use Cases

### Use Case 1: Daily PySpark Practice

**Scenario:** You want to practice PySpark every day for a week.

**Approach:** Set up once, practice, keep resources, clean up at end of week

```bash
# Monday - Initial setup
./mission-deh-hof-setup.sh

# Monday-Friday - Practice in Glue notebook
# (Remember to stop notebook when not in use!)

# Friday - Clean up
./mission-deh-hof-cleanup.sh
```

**Cost:** ~$2-3 for the week (assuming 1 hour/day)

### Use Case 2: Workshop/Training Session

**Scenario:** You're running a training workshop with 10 students.

**Approach:** Each student runs setup in their own AWS account

**Instructions for students:**
```bash
# Each student independently
git clone https://github.com/noordataai/aws-pyspark-infrastructure-automation.git
cd aws-pyspark-infrastructure-automation
chmod +x *.sh
./mission-deh-hof-setup.sh

# Practice for 2 hours

# Clean up
./mission-deh-hof-cleanup.sh
```

**Instructor checklist:**
- [ ] Share repository link in advance
- [ ] Ensure students have AWS accounts
- [ ] Verify AWS CLI is configured
- [ ] Remind about cleanup at end

### Use Case 3: Interview Preparation

**Scenario:** You're preparing for a data engineering interview.

**Approach:** Quick setup, focused practice on specific topics

```bash
# Setup
./mission-deh-hof-setup.sh

# Practice specific topics:
# - Joins (customers + orders)
# - NULL handling (orders with NULL customer_id)
# - Aggregations (order totals by customer)
# - Window functions (running totals)

# After each session
./mission-deh-hof-cleanup.sh
```

**Practice exercises:** See EXERCISES.md (if created)

### Use Case 4: CI/CD Integration

**Scenario:** Automate environment setup for integration tests.

**GitHub Actions example:**
```yaml
name: Integration Tests

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Setup environment
        run: ./mission-deh-hof-setup.sh
      
      - name: Run tests
        run: ./run-tests.sh  # Your test script
      
      - name: Cleanup
        if: always()
        run: ./mission-deh-hof-cleanup.sh
```

---

## Advanced Usage

### Customizing Resource Names

Edit the scripts to use custom names:

```bash
# In mission-deh-hof-setup.sh (line ~37)
# Change from:
BUCKET_NAME="mission-deh-hof-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-glue-role"

# Change to:
BUCKET_NAME="my-custom-name-$ACCOUNT_ID"
ROLE_NAME="my-custom-glue-role"

# Do the same in mission-deh-hof-cleanup.sh
```

### Adding More Datasets

Add additional datasets to the setup script:

```bash
# In mission-deh-hof-setup.sh, after products.csv

# transactions.csv
cat > transactions.csv << 'EOF'
transaction_id,order_id,payment_method,transaction_date
1,101,credit_card,2023-04-01
2,102,paypal,2023-04-02
EOF

# Upload to S3
aws s3 cp transactions.csv "s3://$BUCKET_NAME/raw/transactions.csv" --no-cli-pager
rm -f transactions.csv
```

### Multi-Region Deployment

Modify for different regions:

```bash
# Add region parameter at top of script
REGION=${AWS_REGION:-us-east-1}

# Use in commands
aws s3 mb "s3://$BUCKET_NAME" --region $REGION

# Usage
AWS_REGION=us-west-2 ./mission-deh-hof-setup.sh
```

### Environment Variables

Support for environment-specific resources:

```bash
# Add environment parameter
ENV=${ENVIRONMENT:-dev}
BUCKET_NAME="mission-deh-hof-$ENV-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-$ENV-glue-role"

# Usage
ENVIRONMENT=staging ./mission-deh-hof-setup.sh
```

### Dry-Run Mode

Add dry-run capability:

```bash
# At top of script
DRY_RUN=${DRY_RUN:-false}

# Wrap commands
if [ "$DRY_RUN" = "true" ]; then
    log "[DRY RUN] Would create bucket: $BUCKET_NAME"
else
    aws s3 mb "s3://$BUCKET_NAME"
fi

# Usage
DRY_RUN=true ./mission-deh-hof-setup.sh
```

---

## Best Practices

### 1. Always Clean Up

```bash
# Set a reminder
echo "Remember to run cleanup!" | at now + 2 hours

# Or schedule automatic cleanup
echo "./mission-deh-hof-cleanup.sh" | at 18:00
```

### 2. Monitor AWS Costs

```bash
# Check current month costs
aws ce get-cost-and-usage \
    --time-period Start=2026-08-01,End=2026-08-02 \
    --granularity DAILY \
    --metrics BlendedCost
```

### 3. Use Version Control

```bash
# Track your changes
git init
git add *.sh
git commit -m "Custom configuration"
```

### 4. Document Custom Changes

```bash
# Add a CUSTOM_CHANGES.md file
echo "# My Customizations" > CUSTOM_CHANGES.md
echo "- Changed bucket name to my-org-name" >> CUSTOM_CHANGES.md
```

### 5. Regular Testing

```bash
# Test monthly to ensure compatibility
./mission-deh-hof-setup.sh
# Verify in console
./mission-deh-hof-cleanup.sh
```

---

## FAQ

### Q: Can I run these scripts on Windows?

**A:** Yes, but you need:
- Git Bash (comes with Git for Windows)
- OR Windows Subsystem for Linux (WSL)
- OR Docker with Linux container

**Git Bash example:**
```bash
# In Git Bash
cd /c/Users/YourName/scripts
bash mission-deh-hof-setup.sh
```

### Q: What if the script fails midway?

**A:** The setup script has automatic rollback.

```bash
# Check the log file
cat mission-deh-hof-setup-*.log | tail -50

# Manually verify resources
aws s3 ls | grep mission-deh-hof
aws iam list-roles | grep mission-deh-hof

# Run cleanup if needed
./mission-deh-hof-cleanup.sh
```

### Q: Can I run multiple environments simultaneously?

**A:** Yes, by using custom names:

```bash
# Environment 1 (default)
./mission-deh-hof-setup.sh

# Environment 2 (requires script modification)
# Edit scripts to use different names
BUCKET_NAME="mission-deh-hof-v2-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-v2-glue-role"
```

### Q: How do I check if resources still exist?

**A:**
```bash
# Check S3
aws s3 ls | grep mission-deh-hof

# Check IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `mission-deh-hof`)]'

# Check Glue notebooks
aws glue list-dev-endpoints
```

### Q: What are the AWS charges?

**A:** See detailed breakdown:

| Resource | Cost | Billing |
|----------|------|---------|
| S3 Storage | $0.023/GB/month | < $0.01 for sample data |
| S3 Requests | $0.0004/1000 | < $0.01 |
| IAM Role | FREE | Always free |
| Glue Notebook | $0.44/hour | Only when running |

**Total:** ~$0.50 per practice session (2 hours)

### Q: Can I use this in production?

**A:** Not recommended. These scripts are for:
- Learning
- Development
- Proof-of-concepts
- Training

For production, use:
- AWS CloudFormation
- Terraform
- AWS CDK
- Proper IAM policies (not `*FullAccess`)

### Q: How do I contribute improvements?

**A:** See [CONTRIBUTING.md](CONTRIBUTING.md)

```bash
# Fork repository
# Make changes
# Test thoroughly
# Submit pull request
```

---

## Troubleshooting

See [README.md - Troubleshooting](README.md#-troubleshooting) for common issues and solutions.

---

**Need more help?** Open an issue on GitHub!

*Last Updated: August 2, 2026*
