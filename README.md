# aws-questions
Question 1
You’ve been asked to write a bootstrap script to automate the installation of an
application on an EC2 instance. The application requires a specific password to be
provided during installation. How do you provide this password in a secure manner
during the bootstrap process?

```
I used shush to encrypt and decrypt the password during bootstrap and build timeout

for more info use the below command

make build

```

Question 2
You’ve been asked to provide a user with full access to a specific S3 bucket and all
EC2 instances with a specific tag. Write the IAM policy to provide this access.
S3 Bucket Name: filebucket
EC2 Tag: { Business Unit : org1 }
```
InstanceRole:
  Type: AWS::IAM::Role
  Properties:
    Path: /application/
    AssumeRolePolicyDocument:
      Version: 2012-10-17
      Statement:
      - Effect: Allow
        Principal:
          Service:
          - ec2.amazonaws.com
        Action:
        - sts:AssumeRole
    Policies:
    - PolicyName: s3-secrets-access
      PolicyDocument:
        Version: 2012-10-17
        Statement:
        - Effect: Allow
          Action:
          - s3:*
          Resource: "arn:aws:s3:::service-nsw-prod-secrets/filebucket/"
    - PolicyName: ec2-access
      PolicyDocument:
        Version: 2012-10-17
        Statement:
        - Effect: Allow
          Action:
          - ec2-*
          Resource: "*"  
           Condition:
               StringEquals:
                   ec2:ResourceTag/Business Unit": <org1>


```

Question 3
Your organisation is looking to provision a new AWS account and has asked you to
ensure the following:
A. All API calls in the account are logged, and logs are tamper proof
B. Changes to any resource configuration is logged
C. Strict access policies (2FA, etc) for all user accounts
D. All network traffic is logged
Suggest services that you would configure to accommodate the above requirements.


```
A. Use CloudTrail to  capture all the logs (Amazon EC2, Amazon EBS, and Amazon VPC ) including api calls.

B. Create a trail, and push the logs to kms enabled Amazon S3 bucket.

C. Using IAM you can control access to user account (MFA, password restriction,account age, etc.)

D. CloudWatch and CloudWatch Logs
   VPC Flow Logs
```

Question 4
Your organisation is looking to move their existing 3-tier web application to AWS and
have asked you to come up with a design to accommodate the following:
A. Cater for datacentre outages across all 3 tiers
B. Dynamically scale for performance while being cost effective
C. Provide a self-healing architecture
D. d. Ensure middle tier and backend are not publicly accessible
Using Infrastructure as Code (Cloudformation, Ansible or Terraform) - create scripts to
autodeploy the above
```

I have written the code in https://github.com/semmersultan/aws-questions.git

clone the project and use
make build && make deploy

at this stage this will deploy the web server with all the loggin and monitoring. I can do the same with application and Database deployment .



```
