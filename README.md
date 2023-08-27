# AWS Bucket with MFA delete "Deny"

Create the `.auto.tfvars`:

```terraform
enforce_kms_policy = true
mfa_policy_enabled = true
```

To create the resources:

```sh
terraform init
terraform apply -auto-approve
```

KMS encryption will be enforced with a `"s3:x-amz-server-side-encryption":"aws:kms"` condition.

MFA delete controlled with `"aws:MultiFactorAuthAge"`.

Few notes about SSE-KMS with CMK:

- When using SSE-KMS, S3 automatically applies [envelope encryption][1]. Every object has it's own key.
- KMS CMK key rotation is 365 days.

[1]: https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping
