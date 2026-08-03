#!/bin/bash

LOG_FILE="mission-deh-hof-cleanup-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=========================================="
log "Starting PySpark Skill Booster Cleanup"
log "=========================================="

# Get AWS Account ID
log "Fetching AWS Account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
log "Account ID: $ACCOUNT_ID"

# Define resource names
BUCKET_NAME="mission-deh-hof-$ACCOUNT_ID"
ROLE_NAME="mission-deh-hof-glue-role"

# Delete S3 bucket
log "Deleting S3 bucket: $BUCKET_NAME"
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    aws s3 rb "s3://$BUCKET_NAME" --force --no-cli-pager
    log "✓ S3 bucket deleted"
else
    log "⚠ S3 bucket not found, skipping"
fi

# Detach and delete IAM role
log "Detaching policies from role: $ROLE_NAME"
if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    aws iam detach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole" \
        --no-cli-pager 2>/dev/null || log "⚠ AWSGlueServiceRole policy not attached"
    
    aws iam detach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" \
        --no-cli-pager 2>/dev/null || log "⚠ AmazonS3FullAccess policy not attached"
    
    log "Deleting IAM role: $ROLE_NAME"
    aws iam delete-role --role-name "$ROLE_NAME" --no-cli-pager
    log "✓ IAM role deleted"
else
    log "⚠ IAM role not found, skipping"
fi

log "=========================================="
log "Cleanup completed successfully!"
log "=========================================="
log ""
log "Note: If you created Glue notebooks manually, delete them from the Glue Console"
log "Log file: $LOG_FILE"
