#!/usr/bin/env bash
# This script setups dockerized Redash on MacOS
# https://redash.io/help/open-source/dev-guide/docker
set -eu

export REDASH_BASE_PATH=./redash_conf

create_directories() {
    sudo rm -rf $REDASH_BASE_PATH

    if [[ ! -e $REDASH_BASE_PATH ]]; then
        sudo mkdir -p $REDASH_BASE_PATH
        sudo chown wellytambunan:admin $REDASH_BASE_PATH
    fi

    # if [[ ! -e $REDASH_BASE_PATH/postgres-data ]]; then
    #     sudo mkdir $REDASH_BASE_PATH/postgres-data
    # fi
}

create_config() {
    if [[ -e $REDASH_BASE_PATH/env ]]; then
        sudo rm $REDASH_BASE_PATH/env
        sudo touch $REDASH_BASE_PATH/env
    fi

    COOKIE_SECRET=$(pwgen -1s 32)
    SECRET_KEY=$(pwgen -1s 32)
    POSTGRES_PASSWORD=$(pwgen -1s 32)
    REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres/postgres"

    echo "PYTHONUNBUFFERED=0" >> $REDASH_BASE_PATH/env
    echo "REDASH_LOG_LEVEL=INFO" >> $REDASH_BASE_PATH/env
    echo "REDASH_REDIS_URL=redis://redis:6379/0" >> $REDASH_BASE_PATH/env
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> $REDASH_BASE_PATH/env
    echo "REDASH_COOKIE_SECRET=$COOKIE_SECRET" >> $REDASH_BASE_PATH/env
    echo "REDASH_SECRET_KEY=$SECRET_KEY" >> $REDASH_BASE_PATH/env
    echo "REDASH_DATABASE_URL=$REDASH_DATABASE_URL" >> $REDASH_BASE_PATH/env
}

setup_compose() {
    echo "export COMPOSE_PROJECT_NAME=redash" >> ~/.profile
    echo "export COMPOSE_FILE=./docker-compose.yml" >> ~/.profile

    export COMPOSE_PROJECT_NAME=redash
    export COMPOSE_FILE=./docker-compose.yml

    sudo docker-compose build

    sudo docker-compose run --rm server create_db

    # sudo docker-compose up -d

    sudo docker-compose up
}

create_directories
create_config
# setup_compose
