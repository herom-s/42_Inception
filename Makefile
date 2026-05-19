include ./srcs/.env

export $(grep -v '^#' ./srcs/.env | cut -d= -f1)

all: up

volumes:
	mkdir -p $(VOLUME_MARIADB)
	mkdir -p $(VOLUME_WORDPRESS)
	mkdir -p $(VOLUME_REDIS)

build: volumes
	docker compose -f $(DOCKER_COMPOSE_FILE) build

up: volumes
	docker compose -f $(DOCKER_COMPOSE_FILE) up

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

clean:
	docker compose -f $(DOCKER_COMPOSE_FILE) down --volumes --remove-orphans

fclean:
	docker compose -f $(DOCKER_COMPOSE_FILE) down --volumes --remove-orphans --rmi all
	sudo rm -rf $(VOLUME_MARIADB)
	sudo rm -rf $(VOLUME_WORDPRESS)
	sudo rm -rf $(VOLUME_REDIS)

re: fclean up

logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs -f

.PHONY: all volumes build up down clean fclean re logs
