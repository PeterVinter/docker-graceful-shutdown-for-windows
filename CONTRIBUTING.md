# Contributing to Docker Graceful Shutdown for Windows

Thank you for your interest in contributing to this project! This document provides guidelines and steps for contributing.

## How to Contribute

### 1. Fork and Clone

1. **Fork the Repository**
   - Click the 'Fork' button at the top right of the [repository page](https://github.com/PeterVinter/docker-graceful-shutdown-for-windows)
   - This creates a copy of the repository in your GitHub account

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/docker-graceful-shutdown-for-windows.git
   cd docker-graceful-shutdown-for-windows
   ```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-fix-name
```

Name your branch based on what you're working on:
- Use `feature/` prefix for new features (e.g., `feature/linux-support`)
- Use `fix/` prefix for bug fixes (e.g., `fix/timeout-issue`)

### 3. Make Your Changes

1. Make your changes to the code
2. Test your changes thoroughly
3. Follow the existing code style
4. Add comments where necessary
5. Update documentation if needed

### 4. Commit Your Changes

```bash
git add .
git commit -m "Add: detailed description of your changes"
```

Commit Message Guidelines:
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Start with a capital letter
- Limit the first line to 72 characters
- Reference issues and pull requests when relevant

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Submit a Pull Request

1. Go to your fork on GitHub
2. Click 'New Pull Request'
3. Select your branch
4. Fill in the PR template
5. Submit the PR

## Reporting Issues

When reporting issues, please include:

1. **Description**
   - Clear and descriptive title
   - Detailed description of the issue

2. **Environment**
   - Windows version
   - PowerShell version
   - Docker version
   - Any relevant configuration

3. **Steps to Reproduce**
   - Step-by-step guide to reproduce the issue
   - Example code or commands if applicable

4. **Expected Behavior**
   - What you expected to happen

5. **Actual Behavior**
   - What actually happened
   - Error messages and logs if applicable

6. **Screenshots**
   - If applicable, add screenshots to help explain the issue

## Pull Request Guidelines

1. **Before Submitting**
   - Test your changes thoroughly
   - Update documentation if needed
   - Ensure your code follows existing conventions
   - Add comments where necessary

2. **PR Description**
   - Describe the changes made
   - Link to related issues
   - Note any breaking changes
   - List any new dependencies

3. **Review Process**
   - Maintainers will review your PR
   - Address any requested changes
   - Be responsive to feedback
   - Be patient during the review process

## Code Style Guidelines

1. **PowerShell**
   - Use clear, descriptive variable names
   - Add comments for complex logic
   - Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)

2. **Documentation**
   - Keep documentation up to date
   - Use clear, concise language
   - Include examples where helpful

## Questions?

If you have questions about contributing:
1. Check existing issues and documentation
2. Open a new issue with the question label
3. Be clear and specific in your questions

Thank you for contributing to make this project better!
