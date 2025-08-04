# Static Web App Deployment with Variable Group

This guide explains how to deploy the Static Web App using the existing Variable Group `deployment_token` in Azure DevOps.

## Prerequisites

1. **Variable Group**: Ensure the Variable Group `deployment_token` exists in your Azure DevOps project
2. **Secret Variables**: The Variable Group should contain:
   - `github-token`: Your GitHub Personal Access Token
   - `repository-url` (optional): Your repository URL
   - `branch-name` (optional): Branch name to deploy from

## Variable Group Setup

If you need to verify or update your Variable Group:

1. Go to Azure DevOps → Pipelines → Library
2. Find the Variable Group named `deployment_token`
3. Ensure it contains the required secret variables
4. Make sure the Variable Group has appropriate permissions for your pipeline

## Deployment Options

### Option 1: Azure DevOps Pipeline (Recommended)

Use the provided `azure-pipelines.yml` or `azure-pipelines-arm.yml`:

```yaml
variables:
- group: deployment_token  # References your existing Variable Group

# The pipeline will automatically use $(github-token) from the Variable Group
```

**Steps to set up:**
1. Create a new pipeline in Azure DevOps
2. Point it to either `azure-pipelines.yml` or `azure-pipelines-arm.yml`
3. Update the service connection name in the pipeline file
4. Run the pipeline

### Option 2: PowerShell Script

Use the `deploy.ps1` script locally:

```powershell
# Get the token from your Variable Group or environment
$token = "your-github-token-here"

.\deploy.ps1 -ResourceGroupName "staticwebapp" -RepositoryToken $token
```

### Option 3: Azure CLI Direct

```bash
# Set your token (get this from the Variable Group)
export GITHUB_TOKEN="your-github-token-here"

az deployment group create \
  --resource-group staticwebapp \
  --template-file StaticWebApp.bicep \
  --parameters @parameter.json \
  --parameters repositoryToken="$GITHUB_TOKEN"
```

## Configuration

### Update parameter.json

Make sure to update the repository URL and branch in `parameter.json`:

```json
{
  "repositoryUrl": {
    "value": "https://github.com/your-org/your-repo"
  },
  "branch": {
    "value": "main"
  }
}
```

### Variable Group Variables

Your `deployment_token` Variable Group should contain:

| Variable Name | Type | Description |
|---------------|------|-------------|
| `github-token` | Secret | GitHub Personal Access Token |
| `repository-url` | Variable | Repository URL (optional) |
| `branch-name` | Variable | Branch name (optional) |

## Troubleshooting

### Permission Errors
- Ensure your service principal has Contributor access to the resource group
- Verify the Variable Group permissions allow your pipeline to access it

### Variable Group Access
- Check that your pipeline has access to the `deployment_token` Variable Group
- Verify the Variable Group exists in the correct Azure DevOps project

### Token Issues
- Ensure the GitHub token has appropriate permissions for the repository
- Verify the token hasn't expired

## Security Best Practices

1. **Use Secret Variables**: Always mark sensitive values like tokens as "secret" in Variable Groups
2. **Limit Access**: Restrict Variable Group access to only necessary pipelines/users
3. **Token Scope**: Use GitHub tokens with minimal required permissions
4. **Regular Rotation**: Rotate tokens regularly and update the Variable Group

## Example Pipeline Run

When you run the pipeline, it will:
1. Reference the `deployment_token` Variable Group
2. Extract the `github-token` secret
3. Pass it securely to the Bicep deployment
4. Deploy the Static Web App with the provided configuration

The deployment will no longer try to create a new Variable Group since we're referencing the existing one properly.