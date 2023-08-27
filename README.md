# AWS Bucket with MFA delete "Deny"

Create the `.auto.tfvars`:

```terraform
mfa_policy_enabled = true
```

To create the resources:

```sh
terraform init
terraform apply -auto-approve
```

Few notes about SSE-KMS with CMK:

- When using SSE-KMS, S3 automatically applies [envelope encryption][1]. Every object has it's own key.
- KMS CMK key rotation is 365 days.


[1]: https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping
