Setup process in order
- VirtualBox Ubuntu Server
- Remote SSH from VS Code to utilize the extensions
- Docker Engine <https://docs.docker.com/engine/install/ubuntu/>
- Docker user group
- File Structure and gitignores

- Penultimate Stable Version at 10/12/2025
	- Debian - Bookworm (v12), latest is Trixie (13)
- MariaDB (doesnt depend on anything) (Debian)
- Wordpress (depends on MariaDB) (Debian)
- NGINX (needs wordpress entrypoint) (Alpine)

`docker run --rm -it debian:bookworm-slim bash`
- before finalizing your dockerfile, scripts or config etc, run this, and run all the commands you planned inside
- `--rm` immediately removes the container after it dies
- `docker cp <container_id>:/etc/php/8.2/fpm/pool.d/www.conf ./reference_www.conf.` Stick this in a folder called `/docs` or `.ignore` it. Copies the original config file to host machine, which contains comments and default settings, if you want to overwrite, use any other name after the letter `w` from `www.conf` so the next config file will overwrite the default one, prefix it with `z-` (e.g., `z-custom.conf`)

- `dpkg -L <package>` -- shows all files installed along the package to see what exists, it'll give a list
- `docker exec -it <container> bash` launch bash as seperate process in container
