# Contributing to AWS PySpark Infrastructure Automation Scripts

Thank you for considering contributing to this project! 🎉

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear title** - Briefly describe the issue
2. **Environment details**
   - Operating system (Linux/Mac/Windows)
   - Bash version (`bash --version`)
   - AWS CLI version (`aws --version`)
3. **Steps to reproduce**
   - Exact commands you ran
   - Configuration details
4. **Expected vs actual behavior**
5. **Log files** - Attach relevant log files
6. **Error messages** - Full error text

### Suggesting Features

Feature requests are welcome! Please include:

1. **Use case** - Why this feature is needed
2. **Proposed solution** - How you envision it working
3. **Alternatives** - Other approaches you considered
4. **Examples** - Code snippets or mockups if applicable

### Submitting Pull Requests

#### Before You Start

1. **Check existing issues/PRs** - Avoid duplicate work
2. **Discuss major changes** - Open an issue first for big features
3. **One feature per PR** - Keep changes focused

#### Development Process

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR_USERNAME/aws-pyspark-infrastructure-automation.git
   cd aws-pyspark-infrastructure-automation
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-number
   ```

3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test thoroughly**
   ```bash
   # Test setup
   ./mission-deh-hof-setup.sh
   
   # Verify resources in AWS Console
   
   # Test cleanup
   ./mission-deh-hof-cleanup.sh
   
   # Verify complete removal
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of your changes"
   ```
   
   **Commit message format:**
   - `Add:` New features
   - `Fix:` Bug fixes
   - `Update:` Changes to existing features
   - `Docs:` Documentation only
   - `Refactor:` Code restructuring

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Fill out the PR template
   - Link related issues

#### Pull Request Checklist

- [ ] Code follows existing style
- [ ] Comments added for complex logic
- [ ] Scripts tested on fresh AWS account
- [ ] Documentation updated (README, ARCHITECTURE, etc.)
- [ ] No sensitive data (AWS keys, account IDs) committed
- [ ] Log files excluded (check .gitignore)
- [ ] Scripts remain idempotent
- [ ] Error handling maintained
- [ ] Rollback mechanism intact (for setup script)

### Code Style Guidelines

#### Bash Style

```bash
# Use descriptive variable names in UPPERCASE
BUCKET_NAME="my-bucket"
ROLE_NAME="my-role"

# Functions in lowercase with underscores
function_name() {
    # Implementation
}

# Add comments for non-obvious logic
# Check if bucket exists before creating
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "Bucket exists"
fi

# Use proper error handling
set -e  # Exit on error
trap cleanup_function ERR

# Quote variables to handle spaces
aws s3 cp "$LOCAL_FILE" "s3://$BUCKET_NAME/"

# Use consistent indentation (4 spaces)
if [ condition ]; then
    command
fi
```

#### Documentation Style

- Use clear, concise language
- Include code examples
- Explain the "why" not just the "what"
- Keep line length reasonable (<100 chars)
- Use markdown formatting correctly

### Testing Guidelines

#### Required Tests

1. **Fresh Environment Test**
   - Test on account with no existing resources
   - Verify all resources created correctly

2. **Idempotency Test**
   - Run setup script twice
   - Verify no errors on second run
   - Confirm no duplicate resources

3. **Cleanup Test**
   - Run cleanup after setup
   - Verify all resources removed
   - Check for orphaned resources

4. **Error Handling Test**
   - Simulate failures (wrong permissions, etc.)
   - Verify rollback works correctly
   - Check log files for errors

5. **Multi-Region Test** (if applicable)
   - Test in different AWS regions
   - Verify region-specific behavior

#### Testing Checklist

- [ ] Setup completes without errors
- [ ] All resources created as expected
- [ ] Log files generated correctly
- [ ] Idempotent (can run multiple times)
- [ ] Cleanup removes all resources
- [ ] No orphaned resources remain
- [ ] Error handling triggers correctly
- [ ] Rollback works on failures

### Documentation Updates

When adding features, update:

1. **README.md**
   - Add to relevant sections
   - Update examples
   - Modify table of contents if needed

2. **ARCHITECTURE.md**
   - Document architectural changes
   - Update diagrams if necessary
   - Explain design decisions

3. **Inline Comments**
   - Explain complex logic
   - Document assumptions
   - Note any workarounds

### Review Process

1. **Automated Checks** (if enabled)
   - Shell syntax validation
   - Markdown linting

2. **Manual Review**
   - Code quality
   - Security considerations
   - Documentation accuracy
   - Testing thoroughness

3. **Feedback**
   - Address review comments
   - Push updates to same branch
   - Respond to questions

4. **Merge**
   - Approved PRs merged by maintainers
   - Squash merge for clean history

### Security Considerations

#### Never Commit

- AWS credentials (Access Keys, Secret Keys)
- AWS account IDs in examples (use placeholders)
- Personal information
- Log files with sensitive data

#### Best Practices

- Review code for security issues
- Use IAM best practices
- Follow principle of least privilege
- Validate all inputs
- Handle errors securely (don't expose sensitive info)

### Getting Help

- **Questions?** Open an issue with "Question:" prefix
- **Stuck?** Ask in the issue or PR comments
- **Security issue?** Email maintainer directly (see README)

### Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes (for significant contributions)

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

### Our Standards

**Positive behavior:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

**Unacceptable behavior:**
- Trolling, insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other unprofessional conduct

### Enforcement

Violations may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report issues to the maintainer.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing!** 🙌

Every contribution, no matter how small, makes this project better for everyone.
