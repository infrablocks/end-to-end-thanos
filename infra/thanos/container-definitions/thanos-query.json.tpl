[
  {
    "name": "${thanos_query_container_name}",
    "image": "${thanos_query_container_image}",
    "memoryReservation": 128,
    "essential": true,
    "privileged": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${thanos_query_container_http_port},
        "hostPort": ${thanos_query_host_http_port}
      },
      {
        "containerPort": ${thanos_query_container_grpc_port},
        "hostPort": ${thanos_query_host_grpc_port}
      }
    ],
    "environment": [
      { "name": "AWS_S3_BUCKET_REGION", "value": "$${region}" },
      { "name": "AWS_S3_ENV_FILE_OBJECT_PATH", "value": "${thanos_query_env_file_object_path}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${thanos_query_log_group}",
        "awslogs-region": "$${region}"
      }
    }
  }
]
