[
  {
    "name": "${thanos_compact_container_name}",
    "image": "${thanos_compact_container_image}",
    "memoryReservation": 128,
    "essential": true,
    "privileged": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${thanos_compact_container_http_port},
        "hostPort": ${thanos_compact_host_http_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "thanos-compact-storage",
        "containerPath": "${thanos_compact_storage_location}"
      }
    ],
    "environment": [
      { "name": "AWS_S3_BUCKET_REGION", "value": "$${region}" },
      { "name": "AWS_S3_ENV_FILE_OBJECT_PATH", "value": "${thanos_compact_env_file_object_path}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${thanos_compact_log_group}",
        "awslogs-region": "$${region}"
      }
    }
  }
]
