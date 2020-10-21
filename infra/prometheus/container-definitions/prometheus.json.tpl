[
  {
    "name": "${prometheus_container_name}",
    "image": "${prometheus_container_image}",
    "memoryReservation": 128,
    "essential": true,
    "privileged": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${prometheus_container_http_port},
        "hostPort": ${prometheus_host_http_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-storage",
        "containerPath": "${prometheus_storage_location}"
      }
    ],
    "environment": [
      { "name": "AWS_S3_BUCKET_REGION", "value": "$${region}" },
      { "name": "AWS_S3_ENV_FILE_OBJECT_PATH", "value": "${prometheus_env_file_object_path}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${prometheus_log_group}",
        "awslogs-region": "$${region}"
      }
    }
  },
  {
    "name": "${thanos_sidecar_container_name}",
    "image": "${thanos_sidecar_container_image}",
    "memoryReservation": 128,
    "essential": true,
    "privileged": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${thanos_sidecar_container_http_port},
        "hostPort": ${thanos_sidecar_host_http_port}
      },
      {
        "containerPort": ${thanos_sidecar_container_grpc_port},
        "hostPort": ${thanos_sidecar_host_grpc_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-storage",
        "containerPath": "${prometheus_storage_location}"
      }
    ],
    "environment": [
      { "name": "AWS_S3_BUCKET_REGION", "value": "$${region}" },
      { "name": "AWS_S3_ENV_FILE_OBJECT_PATH", "value": "${thanos_sidecar_env_file_object_path}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${thanos_sidecar_log_group}",
        "awslogs-region": "$${region}"
      }
    }
  }
]
