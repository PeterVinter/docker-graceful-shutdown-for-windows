# Security Policy

## Supported Versions

This project is currently under active development. We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please follow these steps:

1. **Do Not** open a public issue
2. Send a private email to [peter.winther@gmail.com] (replace with your email)
3. Include:
   - A description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

You can expect:
- Acknowledgment of your report within 48 hours
- Regular updates on the progress
- Credit in the security advisory (unless you prefer to remain anonymous)

## Security Best Practices

When using this utility:

1. **Run with Appropriate Permissions**
   - Use minimal required permissions
   - Avoid running as root/admin unless necessary

2. **Environment Security**
   - Keep Docker up to date
   - Keep PowerShell up to date
   - Use latest Windows security updates

3. **Script Verification**
   - Always verify script signatures
   - Download only from official repository
   - Check script contents before execution

## Security Features

This utility includes several security measures:

1. **Safe Container Shutdown**
   - Graceful shutdown to prevent data corruption
   - Proper cleanup of resources

2. **Error Handling**
   - Secure error messages
   - No sensitive information in logs
   - Proper exit codes

## Audit Logging

The script provides basic logging of shutdown operations. Consider enabling Docker's audit logging for additional security monitoring.
