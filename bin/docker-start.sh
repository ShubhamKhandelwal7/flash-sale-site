

# Postgres variables

export DOCKER_PG_IMAGE="609588801065.dkr.ecr.ap-south-1.amazonaws.com/postgres:10.3"
export PG_PASS="mysecretpassword"
export HOST_PG_DATA_DIR="/home/akhil/docker_volumes/postgres-10.3/data"

docker network create si2

# start postgres container
docker run --name pg10    --rm --network si2 -e PGDATA=/var/lib/postgresql/data/pgdata -v $HOST_PG_DATA_DIR:/var/lib/postgresql/data/pgdata -e POSTGRES_PASSWORD=$PG_PASS  -d $DOCKER_PG_IMAGE
