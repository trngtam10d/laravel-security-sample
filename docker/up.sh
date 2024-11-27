#!/bin/bash
[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

install() {
    build
    up
    docker compose exec ${CONTAINER_APP} composer install
    docker compose exec ${CONTAINER_APP} cp .env.example .env
    docker compose exec ${CONTAINER_APP} php artisan key:generate
    docker compose exec ${CONTAINER_APP} php artisan storage:link
    migrate
}

up() {
    docker compose up -d
}

build() {
    docker compose build
}

stop() {
    docker compose stop
}

down() {
    docker compose down --remove-orphans
}

restart() {
    down
    up
}

ps() {
    docker compose ps
}

app() {
    docker compose exec ${CONTAINER_APP} bash
}

migrate() {
    docker compose exec ${CONTAINER_APP} php artisan migrate
}

fresh() {
    docker compose exec ${CONTAINER_APP} php artisan migrate:fresh --seed
}

seed() {
    docker compose exec ${CONTAINER_APP} php artisan db:seed
}

rollback() {
    docker compose exec ${CONTAINER_APP} php artisan migrate:fresh
    docker compose exec ${CONTAINER_APP} php artisan migrate:refresh
}

test() {
    docker compose exec ${CONTAINER_APP} php artisan test
}

optimize() {
    docker compose exec ${CONTAINER_APP} php artisan optimize
}

optimize_clear() {
    docker compose exec ${CONTAINER_APP} php artisan optimize:clear
}

mysql() {
    docker compose exec ${CONTAINER_DB} bash
}

sql() {
    docker compose exec ${CONTAINER_DB} bash -c "chmod 644 /etc/mysql/conf.d/my.cnf"
    docker compose exec ${CONTAINER_DB} bash -c "mysql -u ${USERNAME} -p${PASSWORD} ${PROJECT_NAME} < /var/lib/mysql/library_hajioji.sql"
    seed
}

case "$1" in
    install) install ;;
    up) up ;;
    build) build ;;
    stop) stop ;;
    down) down ;;
    restart) restart ;;
    ps) ps ;;
    app) app ;;
    migrate) migrate ;;
    fresh) fresh ;;
    seed) seed ;;
    rollback) rollback ;;
    test) test ;;
    optimize) optimize ;;
    optimize_clear) optimize_clear ;;
    mysql) mysql ;;
    sql) sql ;;
    *) echo "Usage: $0 {install|up|build|stop|down|restart|ps|app|migrate|fresh|seed|rollback|test|optimize|optimize_clear|mysql|sql}" ;;
esac
