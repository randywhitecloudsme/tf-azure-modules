# Contributing to tf-azure-modules

Thank you for your interest in contributing to this project! This guide will help you get started.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a welcoming environment

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker
- Provide clear descriptions and reproduction steps
- Include Terraform and provider versions
- Share relevant configuration snippets

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-new-feature`
3. **Make your changes** following our guidelines below
4. **Test thoroughly**
5. **Commit with clear messages**: `git commit -am 'Add new feature'`
6. **Push to your fork**: `git push origin feature/my-new-feature`
7. **Open a Pull Request**

## Development Guidelines

### Module Structure

Each module must include:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables with descriptions and validation
- `outputs.tf` - Output values with descriptions
- `versions.tf` - Provider version constraints
- `README.md` - Comprehensive documentation
- `examples/` - At least one working example

### Code Standards

#### Terraform Formatting
```bash
terraform fmt -recursive
```

#### Variable Naming
- Use snake_case for all names
- Be descriptive but concise
- Group related variables

#### Variable Validation
Add validation blocks where appropriate:
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

#### Resource Naming
- Use `this` for single-resource modules
- Use descriptive names for multiple resources
- Avoid redundant prefixes

#### Tags
All resources should support tags:
```hcl
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
```

### Documentation Standards

#### README Requirements
Each module README must include:
1. Description and use cases
2. Usage examples (basic and advanced)
3. Requirements table
4. Inputs table
5. Outputs table
6. Notes and limitations

#### Variable Documentation
```hcl
variable "name" {
  description = "The name of the resource (3-24 characters, alphanumeric and hyphens)"
  type        = string
}
```

#### Output Documentation
```hcl
output "id" {
  description = "The ID of the resource"
  value       = azurerm_resource.this.id
}
```

### Security Best Practices

1. **Sensitive Data**
   - Mark sensitive outputs appropriately
   - Never commit secrets or credentials
   - Use Azure Key Vault for secrets

2. **Network Security**
   - Support private endpoints where applicable
   - Enable encryption by default
   - Follow least-privilege principles

3. **Compliance**
   - Include diagnostic settings
   - Support Azure Policy integration
   - Enable audit logging

### Testing

Before submitting a PR:

1. **Format Check**
   ```bash
   terraform fmt -check -recursive
   ```

2. **Validate**
   ```bash
   cd modules/your-module
   terraform init
   terraform validate
   ```

3. **Test Examples**
   ```bash
   cd modules/your-module/examples/basic
   terraform init
   terraform plan
   ```

4. **Security Scan** (optional but recommended)
   ```bash
   checkov -d modules/your-module
   ```

### Pull Request Guidelines

#### PR Title Format
- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Be descriptive: `feat: add private endpoint support to storage module`

#### PR Description
Include:
- **What**: Summary of changes
- **Why**: Motivation and context
- **How**: Implementation approach
- **Testing**: How you verified the changes
- **Breaking Changes**: If any, with migration guide

#### Example PR Description
```markdown
## What
Adds private endpoint support to the Storage Account module

## Why
Enhances security by allowing storage accounts to be accessed only through private networks

## How
- Added `private_endpoints` variable
- Created `azurerm_private_endpoint` resource
- Updated documentation and examples

## Testing
- Validated with `terraform validate`
- Tested basic example deployment
- Verified private endpoint connectivity

## Breaking Changes
None
```

### Version Bumping

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Release Process

1. Update CHANGELOG.md
2. Create a git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
3. Push tags: `git push origin --tags`
4. Create GitHub release with notes

## Module Enhancement Checklist

When enhancing modules, ensure:

- [ ] Input validation added
- [ ] Lifecycle blocks where appropriate
- [ ] Diagnostic settings supported
- [ ] Private endpoints (if applicable)
- [ ] Encryption enabled by default
- [ ] Tags support
- [ ] Examples updated
- [ ] README updated
- [ ] Tests passing
- [ ] Security scan clean

## Getting Help

- Check existing issues and discussions
- Ask questions in issue comments
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
