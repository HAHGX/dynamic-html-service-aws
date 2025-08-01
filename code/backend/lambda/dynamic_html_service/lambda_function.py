import os
import boto3

def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    param_name = os.environ.get('DYNAMIC_STRING_PARAM_NAME', '/dynamic-html-service/dynamic-string')
    environment_name = os.environ.get('Environment', 'dev')
    response = ssm.get_parameter(Name=param_name)
    dynamic_string = response['Parameter']['Value']
    html = f"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dynamic HTML Challenge</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
          body {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
          }}
          .card {{
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: none;
            border-radius: 15px;
          }}
          .card-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px 15px 0 0 !important;
          }}
          .environment-badge {{
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
          }}
        </style>
      </head>
      <body>
        <div class="container-fluid d-flex align-items-center justify-content-center min-vh-100">
          <div class="row w-100">
            <div class="col-12 col-md-8 col-lg-6 mx-auto">
              <div class="card">
                <div class="card-header text-center py-4">
                  <h1 class="mb-2">
                    <i class="fas fa-code me-2"></i>
                    Dynamic HTML Challenge
                  </h1>
                  <span class="badge environment-badge fs-6">
                    <i class="fas fa-server me-1"></i>
                    {environment_name.title()} Environment
                  </span>
                </div>
                <div class="card-body text-center py-5">
                  <div class="mb-4">
                    <i class="fas fa-database text-primary fs-1 mb-3"></i>
                  </div>
                  <h2 class="text-primary mb-4">
                    Dynamic parameter saved in SSM:
                    <br>
                    <i class="fas fa-quote-left me-2"></i>
                    {dynamic_string}
                    <i class="fas fa-quote-right ms-2"></i>
                  </h2>
                  <div class="row mt-4">
                    <div class="col-12 col-md-6 mb-2">
                      <div class="d-flex align-items-center justify-content-center">
                        <i class="fas fa-cloud text-warning me-2"></i>
                        <small class="text-muted">AWS Lambda</small>
                      </div>
                    </div>
                    <div class="col-12 col-md-6 mb-2">
                      <div class="d-flex align-items-center justify-content-center">
                        <i class="fas fa-cogs text-info me-2"></i>
                        <small class="text-muted">Parameter Store</small>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-footer text-center py-3 bg-light">
                  <small class="text-muted">
                    <i class="fas fa-magic me-1"></i>
                    Author: Hugo Herrera || Powered by Terraform & GitHub Actions
                  </small>
                </div>
              </div>
            </div>
          </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
      </body>
    </html>"""
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/html'},
        'body': html
    }
