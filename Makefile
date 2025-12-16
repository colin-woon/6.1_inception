NAME				=	inception
DOCKER_COMPOSE_FILE	=	./srcs/docker-compose.yml
DATA_PATH			=	/home/cwoon/data

GREEN		= \033[0;32m
RESET		= \033[0m

# .SILENT:

all : up

setup:
	mkdir -p $(DATA_PATH)/mariadb
	echo "$(GREEN) Data volumes created at $(DATA_PATH)$(RESET)"

up : setup
	echo "$(GREEN)Building and starting Inception...$(RESET)"
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build -d

down:
	echo "$(GREEN)Stopping inception...$(RESET)"
	docker compose -f $(DOCKER_COMPOSE_FILE) down

# Clean everything (Containers, Networks, Images, Volumes)
clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker volume prune -f

re: fclean all

.PHONY: all setup up down clean fclean re
