[
  {
    "name": "${thanos_store_container_name}",
    "image": "${thanos_store_container_image}",
    "memoryReservation": 128,
    "essential": true,
    "privileged": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${thanos_store_container_http_port},
        "hostPort": ${thanos_store_host_http_port}
      },
      {
        "containerPort": ${thanos_store_container_grpc_port},
        "hostPort": ${thanos_store_host_grpc_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "thanos-store-storage",
        "containerPath": "${thanos_store_storage_location}"
      }
    ],
    "environment": [
      { "name": "AWS_S3_BUCKET_REGION", "value": "$${region}" },
      { "name": "AWS_S3_ENV_FILE_OBJECT_PATH", "value": "${thanos_store_env_file_object_path}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${thanos_store_log_group}",
        "awslogs-region": "$${region}"
      }
    }
  }
]
