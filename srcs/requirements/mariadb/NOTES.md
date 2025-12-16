### How to check PID 1
- `docker top <container>` shows host machine PID and the container process PID respective to the host, so not a good way to check if the container is PID 1 in its own environment
- `docker exec -it <container> ps aux`, this will show the PID

### Difference between --user=mysql vs --user=${MYSQL_USER}
-

### For Volume custom directories that require root access, thats where the Makefile is useful


### Database credentials should be stored in secrets folder because `docker inspect <container>` will reveal all .env stuff
