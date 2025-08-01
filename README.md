# Dynamic HTML Service - Technical Solution Documentation

**Author:** Hugo Herrera  
**Date:** August 1, 2025  
**Challenge:** Serverless Dynamic HTML Service with Infrastructure as Code  
**Repository:** https://github.com/HAHGX/dynamic-html-service-aws  

---

## Executive Summary

This document presents a comprehensive solution for serving dynamic HTML content using AWS serverless architecture, implemented with Infrastructure as Code (IaC) principles. The solution leverages AWS Lambda, API Gateway v2, Systems Manager Parameter Store, and is fully automated through Terraform and GitHub Actions.

**Live Demo URL:** `https://qdh9wifuld.execute-api.us-east-2.amazonaws.com/`

---

## 1. Solution Architecture

### 1.1 High-Level Architecture

The solution implements a serverless architecture on AWS with the following components:

```
Internet → API Gateway v2 → AWS Lambda → SSM Parameter Store
                ↓
          GitHub Actions ← Terraform ← S3 Backend + DynamoDB Lock
```

### 1.2 Core Components

1. **AWS Lambda Function**
   - Runtime: Python 3.11
   - Function: `dynamic-html-lambda-development`
   - Purpose: Serves dynamic HTML content with Bootstrap styling

2. **API Gateway v2 HTTP API**
   - Protocol: HTTP (more cost-effective than REST)
   - Endpoints: `/` and `/html`
   - Integration: AWS_PROXY with Lambda

3. **AWS Systems Manager Parameter Store**
   - Parameter: `/dynamic-html-service/dynamic-string-development`
   - Type: String
   - Purpose: Stores dynamic content without redeployment

4. **Infrastructure as Code**
   - Tool: Terraform v1.12.0
   - State Management: S3 + DynamoDB locking
   - Multi-environment support: development, staging, production

5. **CI/CD Pipeline**
   - Platform: GitHub Actions
   - Authentication: OIDC (OpenID Connect)
   - Deployment: Comment-triggered via PR commands

---

## 2. Available Options Analysis

### 2.1 Cloud Platform Options

| Platform | Pros | Cons | Decision |
|----------|------|------|----------|
| **AWS** ✅ | Mature serverless ecosystem, extensive IaC support, cost-effective | Vendor lock-in | **Selected** - Best serverless offering |
| Azure | Good integration with Microsoft stack | Less mature serverless options | Not selected |
| GCP | Excellent for data/ML workloads | Smaller ecosystem | Not selected |

### 2.2 Compute Options

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **Lambda** ✅ | True serverless, pay-per-request, auto-scaling | Cold start latency | **Selected** - Perfect for simple HTML serving |
| ECS Fargate | More control, persistent connections | More complex, higher cost | Overkill for this use case |
| EC2 | Full control | Management overhead, always-on costs | Not cost-effective |

### 2.3 Dynamic Content Storage

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **SSM Parameter Store** ✅ | Native AWS integration, free tier, simple | 4KB limit per parameter | **Selected** - Perfect for string storage |
| DynamoDB | Highly scalable, flexible | Overkill, more complex | Not needed for simple strings |
| RDS | Relational features | High cost, unnecessary complexity | Overkill |
| S3 | Unlimited storage | Network latency for small data | Inefficient for small strings |

### 2.4 API Gateway Options

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **API Gateway v2 HTTP** ✅ | 70% cheaper, faster, simpler | Fewer features than REST | **Selected** - Cost-effective for simple use cases |
| API Gateway REST | More features, WAF integration | Higher cost, more complex | Unnecessary features |
| Application Load Balancer | More control | Higher cost, more management | Overkill |

---

## 3. Technical Implementation Details

### 3.1 Lambda Function Architecture

```python
def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    param_name = os.environ.get('DYNAMIC_STRING_PARAM_NAME')
    environment_name = os.environ.get('Environment', 'dev')
    
    # Retrieve dynamic content from Parameter Store
    response = ssm.get_parameter(Name=param_name)
    dynamic_string = response['Parameter']['Value']
    
    # Return styled HTML with Bootstrap
    return styled_html_response(dynamic_string, environment_name)
```

**Key Features:**
- Environment variable configuration
- Error handling for SSM access
- Bootstrap 5.3.0 styling with responsive design
- Font Awesome icons for enhanced UX
- Gradient backgrounds and modern card layout

### 3.2 Infrastructure as Code Structure

```
infra/
├── aws/
│   ├── providers.tf      # AWS provider and S3 backend configuration
│   ├── variables.tf      # Environment and configuration variables
│   ├── lambda.tf         # Lambda function and deployment package
│   ├── apigateway.tf     # API Gateway v2 HTTP API configuration
│   ├── iam.tf           # IAM roles and policies
│   ├── ssm.tf           # Parameter Store configuration
│   └── outputs.tf       # API Gateway URL and other outputs
└── terraform-backend/   # S3 + DynamoDB backend infrastructure
```

### 3.3 Multi-Environment Strategy

- **Terraform Workspaces:** development, staging, production
- **Resource Naming:** All resources include workspace suffix
- **Environment Variables:** Lambda receives environment context
- **Parameter Isolation:** Each environment has separate SSM parameters

### 3.4 Security Implementation

1. **IAM Least Privilege:**
   ```hcl
   resource "aws_iam_policy" "lambda_ssm_policy" {
     policy = jsonencode({
       Statement = [{
         Effect   = "Allow"
         Action   = ["ssm:GetParameter"]
         Resource = aws_ssm_parameter.dynamic_string.arn
       }]
     })
   }
   ```

2. **OIDC Authentication:** GitHub Actions uses OpenID Connect instead of long-lived credentials

3. **State Encryption:** Terraform state encrypted in S3 with DynamoDB locking

4. **API Gateway Throttling:** Rate limiting (1000 req/sec) to prevent abuse

---

## 4. Decision Rationale

### 4.1 Why AWS Lambda?

1. **Cost Efficiency:** Pay only for execution time
2. **Zero Management:** No server maintenance required
3. **Auto Scaling:** Handles traffic spikes automatically
4. **Fast Development:** Quick deployment and testing cycles

### 4.2 Why API Gateway v2 HTTP?

1. **Cost:** 70% cheaper than REST API Gateway
2. **Performance:** Lower latency and faster processing
3. **Simplicity:** Easier configuration for simple use cases
4. **HTTP/2 Support:** Better performance for modern clients

### 4.3 Why Parameter Store over Database?

1. **Simplicity:** No connection management or schema design
2. **Cost:** Free tier covers typical usage
3. **Native Integration:** Built-in AWS service with IAM integration
4. **Immediate Consistency:** Changes available instantly

### 4.4 Why Terraform over CloudFormation?

1. **Multi-Cloud:** Not locked to AWS-specific tooling
2. **State Management:** Superior state tracking and planning
3. **Community:** Larger ecosystem and module library
4. **Language:** HCL is more readable than JSON/YAML

### 4.5 Why GitHub Actions over Jenkins/Other CI/CD?

1. **Integration:** Native Git integration with PR workflows
2. **Security:** OIDC eliminates long-lived credentials
3. **Cost:** Free tier generous for small projects
4. **Simplicity:** No infrastructure to maintain

---

## 5. Deployment and Usage

### 5.1 Automated Deployment

The solution implements an Atlantis-style PR comment deployment system:

```yaml
# Trigger deployment with PR comments
/terraform plan development
/terraform apply development
/terraform destroy development
```

### 5.2 Changing Dynamic Content

To update the displayed string without redeployment:

```bash
aws ssm put-parameter \
  --name "/dynamic-html-service/dynamic-string-development" \
  --value "Your new dynamic content here" \
  --overwrite \
  --region us-east-2
```

The change is immediately visible on the next page load.

### 5.3 Multi-Environment Workflow

1. **Development:** `terraform workspace select development`
2. **Staging:** `terraform workspace select staging`
3. **Production:** `terraform workspace select production`

Each environment has isolated resources and parameters.

---

## 6. Future Enhancements

### 6.1 Short-term Improvements (1-2 weeks)

1. **CloudFront Distribution**
   - Add CDN for global performance
   - Enable WAF for security protection
   - Custom domain with SSL certificate

2. **Enhanced Monitoring**
   - CloudWatch dashboards
   - Lambda performance metrics
   - API Gateway access logs
   - SNS alerts for errors

3. **Content Management**
   - Simple web interface for parameter updates
   - Parameter history and versioning
   - Multi-parameter support for complex content

### 6.2 Medium-term Enhancements (1-2 months)

1. **Advanced Security**
   - API key authentication
   - Request/response logging
   - Compliance scanning (OWASP)
   - Vulnerability assessments

2. **Performance Optimization**
   - Lambda provisioned concurrency
   - Response caching strategies
   - Database migration for complex data
   - Content compression

3. **DevOps Maturity**
   - Automated testing pipeline
   - Blue/green deployments
   - Rollback mechanisms
   - Infrastructure drift detection

### 6.3 Long-term Vision (3-6 months)

1. **Multi-Region Deployment**
   - Active-active setup across regions
   - Route 53 health checks
   - Global parameter replication
   - Disaster recovery automation

2. **Advanced Features**
   - Real-time content updates via WebSockets
   - A/B testing framework
   - Analytics and user tracking
   - Content personalization

3. **Enterprise Readiness**
   - SAML/SSO integration
   - Audit logging compliance
   - Backup and recovery procedures
   - Cost optimization automation

---

## 7. Cost Analysis

### 7.1 Current Solution Cost (Monthly)

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 1M requests, 128MB, 100ms avg | $0.20 |
| API Gateway v2 | 1M requests | $1.00 |
| Parameter Store | 10K API calls | $0.00 (free tier) |
| S3 (state) | 1GB storage | $0.02 |
| DynamoDB (locking) | Minimal usage | $0.00 (free tier) |
| **Total** | | **~$1.22/month** |

### 7.2 Scaling Projections

- **10M requests/month:** ~$12
- **100M requests/month:** ~$120
- **1B requests/month:** ~$1,200

The serverless model provides excellent cost scaling characteristics.

---

## 8. Testing and Validation

### 8.1 Manual Testing Performed

1. ✅ **Basic Functionality:** HTML page loads correctly
2. ✅ **Dynamic Content:** Parameter changes reflect immediately
3. ✅ **Multi-Environment:** Different workspaces work independently
4. ✅ **Error Handling:** Graceful degradation when parameters unavailable
5. ✅ **Responsive Design:** Mobile and desktop compatibility

### 8.2 Automated Testing Strategy

Future implementations should include:

- Unit tests for Lambda function logic
- Integration tests for API Gateway endpoints
- Infrastructure tests with Terratest
- Performance tests with artillery.js
- Security scanning with tools like Checkov

---

## 9. Lessons Learned

### 9.1 Technical Insights

1. **API Gateway v2 vs WAF:** HTTP APIs don't support WAF directly
2. **Parameter Store ARNs:** Environment-specific naming requires careful IAM policies
3. **Lambda Cold Starts:** Minimal impact for simple HTML serving
4. **Terraform State:** Proper backend configuration is crucial for team collaboration

### 9.2 Process Improvements

1. **PR-driven Deployments:** Comment-triggered deployments improve control
2. **Multi-workspace Strategy:** Environment isolation reduces deployment risks
3. **OIDC Authentication:** More secure than long-lived access keys
4. **Documentation:** Comprehensive docs accelerate team onboarding

---

## 10. Conclusion

This solution demonstrates a modern, cost-effective approach to serving dynamic HTML content using AWS serverless technologies. The implementation showcases:

- **Infrastructure as Code** best practices with Terraform
- **Serverless-first** architecture for minimal operational overhead
- **Security-conscious** design with least-privilege IAM policies
- **Cost-optimized** resource selection
- **Developer-friendly** deployment workflows

The solution successfully meets all challenge requirements:
- ✅ Serves HTML page from cloud infrastructure
- ✅ Implements Infrastructure as Code
- ✅ Supports dynamic content updates without redeployment
- ✅ Provides consistent results for all users
- ✅ Includes comprehensive source code documentation

The modular, well-documented approach enables easy extension and maintenance, making it suitable for both demonstration purposes and production deployment.

---

## Appendix A: Repository Structure

```
dynamic-html-service-aws/
├── README.md
├── code/
│   └── backend/
│       └── lambda/
│           └── dynamic_html_service/
│               └── lambda_function.py
├── infra/
│   ├── aws/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── lambda.tf
│   │   ├── apigateway.tf
│   │   ├── iam.tf
│   │   ├── ssm.tf
│   │   └── outputs.tf
│   └── terraform-backend/
│       ├── dynamodb.tf
│       ├── iam.tf
│       └── s3.tf
├── .github/
│   └── workflows/
│       ├── auto-plan-on-changes.yaml
│       ├── pr-commands.yaml
│       └── deploy-development.yaml
└── Dynamic_HTML_Service_Solution_Documentation.md
```

## Appendix B: Key Commands

```bash
# Deploy infrastructure
terraform init
terraform workspace select development
terraform plan
terraform apply

# Update dynamic content
aws ssm put-parameter \
  --name "/dynamic-html-service/dynamic-string-development" \
  --value "New content" \
  --overwrite

# View logs
aws logs filter-log-events \
  --log-group-name "/aws/lambda/dynamic-html-lambda-development"
```

---

**Document Version:** 1.0  
**Last Updated:** August 1, 2025  
**Contact:** Hugo Herrera  
**Repository:** https://github.com/HAHGX/dynamic-html-service-aws
