#!/bin/bash

LOG_FILE="mission-deh-hof-setup-$(date +%Y%m%d-%H%M%S).log"
CREATED_RESOURCES=()

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cleanup_on_failure() {
    log "ERROR: Unexpected error occurred. Rolling back newly created resources..."
    
    if [[ " ${CREATED_RESOURCES[@]} " =~ " S3_BUCKET " ]]; then
        log "Deleting S3 bucket: $BUCKET_NAME"
        aws s3 rb "s3://$BUCKET_NAME" --force 2>/dev/null || true
    fi
    
    if [[ " ${CREATED_RESOURCES[@]} " =~ " IAM_ROLE " ]]; then
        log "Detaching policies from role: $ROLE_NAME"
        aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole" 2>/dev/null || true
        aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" 2>/dev/null || true
        log "Deleting IAM role: $ROLE_NAME"
        aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null || true
    fi
    
    log "Rollback completed. Check log file: $LOG_FILE"
    exit 1
}

trap cleanup_on_failure ERR

log "=========================================="
log "Starting PySpark Skill Booster Setup"
log "=========================================="

# Get AWS Account ID
log "Fetching AWS Account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
log "Account ID: $ACCOUNT_ID"

# Define resource names
BUCKET_NAME="mission-deh-hof-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-glue-role"
TRUST_POLICY_FILE="mission-deh-hof-trust-policy.json"

# Create S3 bucket
log "Creating S3 bucket: $BUCKET_NAME"
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    log "⚠ S3 bucket already exists, skipping creation"
else
    aws s3 mb "s3://$BUCKET_NAME" --region us-east-1
    CREATED_RESOURCES+=("S3_BUCKET")
    log "✓ S3 bucket created successfully"
fi

# Create sample datasets
log "Generating sample datasets..."

# customers.csv
cat > customers.csv << 'EOF'
customer_id,name,email,country,signup_date
1,John Smith,john.smith@email.com,USA,2023-01-15
2,Maria Garcia,maria.garcia@email.com,Spain,2023-02-20
3,Li Wei,li.wei@email.com,China,2023-01-10
4,Ahmed Hassan,ahmed.hassan@email.com,Egypt,2023-03-05
5,Anna Mueller,anna.mueller@email.com,Germany,2023-02-28
6,Carlos Silva,carlos.silva@email.com,Brazil,2023-01-25
7,Yuki Tanaka,yuki.tanaka@email.com,Japan,2023-03-12
8,Sarah Johnson,sarah.johnson@email.com,USA,2023-02-14
9,Pierre Dubois,pierre.dubois@email.com,France,2023-01-30
10,Priya Sharma,priya.sharma@email.com,India,2023-03-08
EOF

# orders.csv
cat > orders.csv << 'EOF'
order_id,customer_id,product_id,quantity,order_date,amount
101,1,501,2,2023-04-01,199.98
102,2,502,1,2023-04-02,49.99
103,1,503,3,2023-04-03,89.97
104,3,501,1,2023-04-04,99.99
105,4,504,2,2023-04-05,159.98
106,5,502,4,2023-04-06,199.96
107,6,505,1,2023-04-07,299.99
108,NULL,501,2,2023-04-08,199.98
109,8,503,1,2023-04-09,29.99
110,9,504,3,2023-04-10,239.97
111,10,502,2,2023-04-11,99.98
112,NULL,505,1,2023-04-12,299.99
113,2,501,1,2023-04-13,99.99
114,3,503,5,2023-04-14,149.95
115,4,504,1,2023-04-15,79.99
EOF

# products.csv
cat > products.csv << 'EOF'
product_id,product_name,category,price,stock_quantity
501,Wireless Mouse,Electronics,99.99,150
502,USB Cable,Electronics,49.99,300
503,Notebook,Stationery,29.99,200
504,Desk Lamp,Furniture,79.99,80
505,Office Chair,Furniture,299.99,45
506,Keyboard,Electronics,129.99,NULL
EOF

log "✓ Sample datasets generated"

# Upload datasets to S3
log "Uploading datasets to S3..."
aws s3 cp customers.csv "s3://$BUCKET_NAME/raw/customers.csv" --no-cli-pager
aws s3 cp orders.csv "s3://$BUCKET_NAME/raw/orders.csv" --no-cli-pager
aws s3 cp products.csv "s3://$BUCKET_NAME/raw/products.csv" --no-cli-pager
log "✓ Datasets uploaded to s3://$BUCKET_NAME/raw/"

# Clean up local CSV files
rm -f customers.csv orders.csv products.csv

# Create IAM trust policy
log "Creating IAM trust policy..."
cat > "$TRUST_POLICY_FILE" << 'EOF'
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
EOF

# Create IAM role
log "Creating IAM role: $ROLE_NAME"
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null > /dev/null; then
    log "⚠ IAM role already exists, skipping creation"
else
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document "file://$TRUST_POLICY_FILE" \
        --no-cli-pager > /dev/null
    CREATED_RESOURCES+=("IAM_ROLE")
    log "✓ IAM role created"
fi

# Attach policies
log "Attaching policies to IAM role..."
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole" \
    --no-cli-pager 2>/dev/null || log "⚠ AWSGlueServiceRole policy already attached"
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" \
    --no-cli-pager 2>/dev/null || log "⚠ AmazonS3FullAccess policy already attached"
log "✓ Policies attached"

# Add PassRole inline policy
log "Adding PassRole inline policy..."
cat > passrole-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
    }
  ]
}
EOF

aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "PassRolePolicy" \
    --policy-document "file://passrole-policy.json" \
    --no-cli-pager 2>/dev/null || log "⚠ PassRole policy already attached"
rm -f passrole-policy.json
log "✓ PassRole policy added"

# Clean up trust policy file
rm -f "$TRUST_POLICY_FILE"

log "=========================================="
log "Setup completed successfully!"
log "=========================================="
log ""
log "Resources created:"
log "  - S3 Bucket: $BUCKET_NAME"
log "  - IAM Role: $ROLE_NAME"
log "  - Sample datasets uploaded to: s3://$BUCKET_NAME/raw/"
log ""
log "Next steps:"
log "  1. Go to AWS Glue Console"
log "  2. Navigate to ETL > Notebooks (or Glue Studio > Notebooks)"
log "  3. Click 'Create notebook'"
log "  4. Select IAM role: $ROLE_NAME"
log "  5. Once notebook starts, use 'Upload files' button to upload the .ipynb files"
log "  6. Open each notebook and run the cells sequentially"
log ""
log "Log file: $LOG_FILE"
