# 🤖 Prompt Templates for Creating Similar Scripts

This document provides prompt templates you can use with AI assistants (like ChatGPT, Claude, etc.) to create similar AWS automation scripts for your specific needs.

---

## Table of Contents
- [Basic Template](#basic-template)
- [S3 + Lambda Setup](#s3--lambda-setup)
- [RDS Database Setup](#rds-database-setup)
- [EC2 Instance Setup](#ec2-instance-setup)
- [Multi-Service Setup](#multi-service-setup)
- [Customization Examples](#customization-examples)

---

## Basic Template

Use this template as a starting point for any AWS automation:

### Prompt:

```
Create two bash scripts for AWS resource automation:

1. SETUP SCRIPT (setup.sh) that:
   - Fetches the AWS account ID using `aws sts get-caller-identity`
   - Creates an S3 bucket with unique name: {YOUR_PROJECT_NAME}-{ACCOUNT_ID}
   - [ADD YOUR SPECIFIC REQUIREMENTS HERE]
   - Creates an IAM role named: {YOUR_PROJECT_NAME}-role
   - Attaches these IAM policies:
     * [LIST YOUR REQUIRED AWS MANAGED POLICIES]
   - Implements automatic rollback on failure using bash trap
   - Tracks created resources in an array
   - Logs all operations with timestamps to: setup-{TIMESTAMP}.log
   - Checks if resources already exist before creating (idempotent)
   - Uses --no-cli-pager flag for all AWS CLI commands
   - Provides clear next steps after completion

2. CLEANUP SCRIPT (cleanup.sh) that:
   - Fetches AWS account ID
   - Deletes the S3 bucket and all contents using --force
   - Detaches all IAM policies from the role
   - Deletes inline policies automatically
   - Deletes the IAM role
   - Logs all operations with timestamps to: cleanup-{TIMESTAMP}.log
   - Handles missing resources gracefully (no errors)
   - Confirms completion

REQUIREMENTS:
   - Use bash 4.0+ features
   - Implement trap for error handling: trap cleanup_on_failure ERR
   - Create timestamped log files
   - Use log() function: log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
   - Check resource existence before operations
   - Provide success (✓) and warning (⚠) indicators
   - Include detailed inline comments
   - Make scripts idempotent
   - Use variables for resource names at the top

OPTIONAL ENHANCEMENTS:
   - Add dry-run mode (DRY_RUN=true)
   - Support multiple regions via environment variable
   - Add resource tagging for cost tracking
   - Include email notifications (SNS)
   - Add validation checks before operations
```

### How to Use:
1. Copy the prompt above
2. Replace `{YOUR_PROJECT_NAME}` with your project name
3. Add your specific requirements in [ADD YOUR SPECIFIC REQUIREMENTS HERE]
4. List your required IAM policies
5. Submit to your AI assistant

---

## S3 + Lambda Setup

For creating S3 buckets with Lambda functions:

### Prompt:

```
Create two bash scripts for AWS S3 + Lambda automation:

1. SETUP SCRIPT that:
   - Fetches AWS account ID
   - Creates S3 bucket: {PROJECT_NAME}-{ACCOUNT_ID}
   - Creates S3 bucket folder structure:
     * input/
     * output/
     * archive/
   - Uploads sample test file to input/
   - Creates Lambda execution IAM role: {PROJECT_NAME}-lambda-role
   - Attaches policies:
     * AWSLambdaBasicExecutionRole
     * AmazonS3FullAccess
   - Creates Lambda function from local zip file: function.zip
   - Sets Lambda environment variables:
     * BUCKET_NAME={PROJECT_NAME}-{ACCOUNT_ID}
     * INPUT_FOLDER=input
     * OUTPUT_FOLDER=output
   - Creates S3 event notification to trigger Lambda on new files
   - Implements error rollback
   - Logs everything

2. CLEANUP SCRIPT that:
   - Removes S3 event notifications
   - Deletes Lambda function
   - Deletes all S3 objects and bucket
   - Detaches and deletes IAM role
   - Logs everything

ADDITIONAL REQUIREMENTS:
   - Lambda runtime: python3.9
   - Lambda timeout: 60 seconds
   - Lambda memory: 512MB
   - S3 event filter: *.csv in input/ folder

Please include:
   - Sample Lambda function code (Python)
   - Instructions for creating function.zip
   - Example test file content
```

---

## RDS Database Setup

For creating RDS database instances:

### Prompt:

```
Create two bash scripts for AWS RDS automation:

1. SETUP SCRIPT that:
   - Fetches AWS account ID
   - Creates RDS parameter group: {PROJECT_NAME}-params
   - Creates RDS subnet group using default VPC subnets
   - Creates security group: {PROJECT_NAME}-db-sg
     * Allows PostgreSQL port 5432 from your IP
   - Creates RDS PostgreSQL instance:
     * Identifier: {PROJECT_NAME}-db
     * Engine: postgres
     * Version: 14
     * Instance class: db.t3.micro
     * Storage: 20GB GP2
     * Master username: admin
     * Auto-generate password and save to AWS Secrets Manager
   - Creates IAM role for RDS monitoring
   - Waits for DB instance to become available
   - Outputs connection endpoint
   - Implements error rollback
   - Logs everything

2. CLEANUP SCRIPT that:
   - Creates final snapshot: {PROJECT_NAME}-final-snapshot
   - Deletes RDS instance
   - Waits for deletion to complete
   - Deletes subnet group
   - Deletes parameter group
   - Deletes security group
   - Deletes secret from Secrets Manager
   - Logs everything

SAFETY FEATURES:
   - Prompt for confirmation before deleting database
   - Always create final snapshot
   - Skip deletion if --skip-final-snapshot flag provided
   - Validate DB instance name before deletion
```

---

## EC2 Instance Setup

For creating EC2 instances:

### Prompt:

```
Create two bash scripts for AWS EC2 automation:

1. SETUP SCRIPT that:
   - Fetches AWS account ID
   - Creates security group: {PROJECT_NAME}-sg
     * SSH (port 22) from your IP
     * HTTP (port 80) from anywhere
     * HTTPS (port 443) from anywhere
   - Creates key pair: {PROJECT_NAME}-keypair
     * Saves private key to: ~/.ssh/{PROJECT_NAME}-keypair.pem
     * Sets permissions: chmod 400
   - Launches EC2 instance:
     * AMI: Amazon Linux 2 (latest)
     * Instance type: t2.micro
     * Storage: 20GB GP2
     * Tags: Name={PROJECT_NAME}, Environment=dev
   - Creates and attaches IAM role:
     * Role name: {PROJECT_NAME}-ec2-role
     * Policies: AmazonSSMManagedInstanceCore, CloudWatchAgentServerPolicy
   - Waits for instance to be running
   - Allocates and associates Elastic IP
   - Outputs:
     * Instance ID
     * Public IP
     * SSH command
   - Implements error rollback
   - Logs everything

2. CLEANUP SCRIPT that:
   - Terminates EC2 instance
   - Waits for termination
   - Releases Elastic IP
   - Deletes security group
   - Deletes key pair
   - Deletes saved private key
   - Detaches and deletes IAM role
   - Logs everything

USER DATA SCRIPT:
Include a user data script that:
   - Updates all packages
   - Installs Docker
   - Installs CloudWatch agent
   - Creates welcome message in /etc/motd
```

---

## Multi-Service Setup

For complex multi-service environments:

### Prompt:

```
Create two bash scripts for a complete AWS data pipeline automation:

1. SETUP SCRIPT that creates:

   A. Storage Layer:
      - S3 bucket: {PROJECT_NAME}-data-{ACCOUNT_ID}
      - Folder structure: raw/, processed/, archive/
      - Lifecycle policy: Archive to Glacier after 90 days

   B. Database Layer:
      - DynamoDB table: {PROJECT_NAME}-metadata
      - Partition key: file_id (String)
      - Sort key: timestamp (Number)
      - GSI: status-index (for querying by processing status)

   C. Processing Layer:
      - Lambda function: {PROJECT_NAME}-processor
      - Triggered by S3 events
      - Writes metadata to DynamoDB
      - Runtime: Python 3.9, Timeout: 300s, Memory: 1024MB

   D. IAM Layer:
      - Lambda execution role with:
        * S3 read/write access
        * DynamoDB write access
        * CloudWatch Logs access
      - Glue job role with:
        * S3 full access
        * Glue service permissions

   E. Monitoring Layer:
      - CloudWatch log groups for Lambda
      - CloudWatch alarm for Lambda errors
      - SNS topic for notifications
      - Subscribe your email to SNS topic

2. CLEANUP SCRIPT that:
   - Removes all S3 event notifications
   - Deletes Lambda function
   - Deletes DynamoDB table
   - Empties and deletes S3 bucket
   - Deletes CloudWatch log groups
   - Deletes CloudWatch alarms
   - Deletes SNS topic and subscriptions
   - Detaches and deletes all IAM roles
   - Logs everything

INTEGRATION FEATURES:
   - All resources properly connected
   - Environment variables set correctly
   - Resource tags: Project={PROJECT_NAME}, ManagedBy=Script
   - Dependency ordering (create IAM roles before resources that use them)
   - Proper waits for async operations

ERROR HANDLING:
   - Comprehensive rollback for all resources
   - Track creation order for proper rollback sequence
   - Handle partial failures gracefully
```

---

## Customization Examples

### Example 1: Adding Custom Datasets

**Original requirement:**
> "Generate 3 CSV files: customers, orders, products"

**Modified prompt:**
```
Generate 5 CSV files with the following structure:

1. users.csv:
   - user_id, username, email, registration_date, country

2. posts.csv:
   - post_id, user_id, title, content, created_at

3. comments.csv:
   - comment_id, post_id, user_id, comment_text, created_at

4. likes.csv:
   - like_id, post_id, user_id, liked_at

5. tags.csv:
   - tag_id, tag_name, post_id

Include realistic sample data with:
- 20 users from 5 different countries
- 50 posts
- 100 comments
- 200 likes
- 30 unique tags
```

### Example 2: Different AWS Service

**For AWS Kinesis + Firehose:**
```
Replace S3 bucket creation with:

1. Kinesis Data Stream:
   - Stream name: {PROJECT_NAME}-stream
   - Shard count: 1
   - Retention: 24 hours

2. Kinesis Firehose:
   - Delivery stream: {PROJECT_NAME}-firehose
   - Source: Kinesis Data Stream above
   - Destination: S3 bucket (create this too)
   - Buffering: 5MB or 300 seconds
   - Compression: GZIP

3. IAM role for Firehose:
   - Trust relationship with firehose.amazonaws.com
   - Permissions to read from Kinesis
   - Permissions to write to S3
```

### Example 3: Adding Notifications

**Add SNS notifications:**
```
Add SNS integration:

1. In setup script, also:
   - Create SNS topic: {PROJECT_NAME}-notifications
   - Subscribe email address (passed as parameter)
   - Send test message after setup completes
   - Send error notification if rollback triggered

2. In cleanup script:
   - Send notification before cleanup starts
   - Send confirmation after cleanup completes
   - Delete SNS topic

Include email parameter validation:
   - Check email format with regex
   - Confirm subscription link in logs
```

### Example 4: Multi-Region Support

**Add region flexibility:**
```
Modify scripts to support multiple AWS regions:

1. Add region parameter:
   - Default: us-east-1
   - Accept from environment variable: AWS_REGION
   - Accept from command line argument: --region

2. Update all AWS CLI commands:
   - Add --region $REGION flag
   - Handle region-specific limitations

3. Use region-specific naming:
   - Bucket: {PROJECT_NAME}-{REGION}-{ACCOUNT_ID}
   - Role: {PROJECT_NAME}-{REGION}-role

4. Validate region:
   - Check if region exists
   - Confirm service availability in region

Usage examples:
   AWS_REGION=us-west-2 ./setup.sh
   ./setup.sh --region eu-west-1
```

### Example 5: Adding Dry-Run Mode

**Add safe preview mode:**
```
Add dry-run capability:

1. Check for DRY_RUN environment variable
2. If enabled:
   - Print what would be created (don't create)
   - Show AWS CLI commands that would run
   - Estimate costs
   - No actual resource creation

3. Output format:
   [DRY RUN] Would create S3 bucket: my-bucket-123456789012
   [DRY RUN] Would execute: aws s3 mb s3://my-bucket-123456789012
   [DRY RUN] Estimated cost: $0.023/month

4. Usage:
   DRY_RUN=true ./setup.sh
```

---

## Validation Checklist

When reviewing AI-generated scripts, verify:

- [ ] Error handling with trap
- [ ] Resource tracking for rollback
- [ ] Idempotency (check if exists before create)
- [ ] Timestamped logging
- [ ] AWS CLI --no-cli-pager flags
- [ ] Proper IAM trust relationships
- [ ] Security group rules are not too permissive
- [ ] No hardcoded credentials
- [ ] Variables at top for easy customization
- [ ] Clear success/warning messages
- [ ] Cleanup script matches setup script
- [ ] Documentation/comments included

---

## Tips for Better Prompts

### 1. Be Specific About Structure

❌ **Vague:** "Create a setup script"

✅ **Specific:** "Create a bash script with log() function, trap error handling, and CREATED_RESOURCES array"

### 2. Include Real-World Constraints

❌ **Generic:** "Create an S3 bucket"

✅ **Realistic:** "Create an S3 bucket with encryption enabled, versioning, and lifecycle policy to archive after 30 days"

### 3. Specify Error Handling

❌ **Minimal:** "Handle errors"

✅ **Comprehensive:** "Implement trap to catch errors, rollback only newly created resources (track in array), log all rollback actions, exit with code 1"

### 4. Request Examples

❌ **Script only:** "Create the scripts"

✅ **Complete:** "Create the scripts AND include example usage, sample data, and expected output"

### 5. Ask for Security Best Practices

❌ **Unsecure:** "Create IAM role with S3 access"

✅ **Secure:** "Create IAM role with minimum required S3 permissions (list and get objects only, scoped to specific bucket), include trust relationship with least privilege"

---

## Iterative Refinement

After getting initial scripts, refine with follow-up prompts:

### Follow-up Prompt 1: Add Validation
```
Add input validation to the scripts:
- Verify AWS CLI is installed
- Check AWS credentials are configured
- Validate AWS region
- Confirm required IAM permissions before starting
- Exit gracefully with helpful error messages if validation fails
```

### Follow-up Prompt 2: Improve Logging
```
Enhance the logging:
- Add log levels (INFO, WARN, ERROR)
- Color-code output (green for success, yellow for warning, red for error)
- Create separate error log file
- Add progress indicators for long operations
```

### Follow-up Prompt 3: Add Tests
```
Create a test script that:
- Runs setup script
- Verifies all resources created correctly
- Checks resource configurations
- Runs cleanup script
- Verifies all resources deleted
- Reports test results
```

---

## Real Example: From Prompt to Script

### Initial Prompt:
```
Create bash scripts to set up an AWS environment for learning PySpark with AWS Glue.
Include S3 bucket for data, sample CSV files, and IAM role for Glue.
```

### Refined Prompt (Better):
```
Create two bash scripts for AWS PySpark learning environment:

1. SETUP SCRIPT:
   - Create S3 bucket: mission-deh-hof-{ACCOUNT_ID}
   - Generate 3 CSV files: customers (10 rows), orders (15 rows, some NULLs), products (6 rows)
   - Upload CSVs to s3://{bucket}/raw/
   - Create IAM role: mission-deh-hof-glue-role
   - Attach: AWSGlueServiceRole, AmazonS3FullAccess
   - Add PassRole inline policy
   - Implement rollback on errors
   - Log all operations

2. CLEANUP SCRIPT:
   - Delete S3 bucket and contents
   - Detach policies and delete IAM role
   - Log all operations

Requirements:
   - Bash 4.0+
   - Idempotent (can run multiple times)
   - Timestamped logs
   - Check resource existence before creation
```

### Result:
This refined prompt produces the scripts you see in this repository!

---

## Template Library

### Quick Reference

| Use Case | Template Name | Complexity |
|----------|---------------|------------|
| S3 + IAM only | Basic Template | ⭐ Simple |
| S3 + Lambda | Lambda Template | ⭐⭐ Medium |
| S3 + Glue + IAM | PySpark Template (this repo) | ⭐⭐ Medium |
| RDS Database | RDS Template | ⭐⭐⭐ Complex |
| EC2 + Security | EC2 Template | ⭐⭐⭐ Complex |
| Full Pipeline | Multi-Service Template | ⭐⭐⭐⭐ Advanced |

---

## Contributing Your Templates

Have a great prompt template? Contribute it!

1. Test your prompt thoroughly
2. Document the use case
3. Include example output
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

**Happy Automating!** 🤖

*Last Updated: August 2, 2026*
