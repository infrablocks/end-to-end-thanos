{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PrometheusStorageBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${prometheus_storage_bucket_name}/*",
        "arn:aws:s3:::${prometheus_storage_bucket_name}"
      ]
    },
    {
      "Sid": "SecretsBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${secrets_bucket_name}/*",
        "arn:aws:s3:::${secrets_bucket_name}"
      ]
    }
  ]
}