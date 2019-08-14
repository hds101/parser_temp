#!/bin/bash
set -e
while ! nc -z rabbitmq 5672; do sleep 3; done
exec "$@"
