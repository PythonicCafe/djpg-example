# djpg-example

You need docker compose to run this project.

Running all services:

```shell
make start logs
```

To access Django, go to [localhost:5000](http://localhost:5000).

Running the first migration:

```shell
make migrate
# or `make bash` and then `python manage.py migrate` inside the container
```

Creating Django's super user:

```shell
docker compose exec -it web python manage.py createsuperuser
# or `make bash` and then `python manage.py createsuperuser` inside the container
```

Running tests (outside container):

```shell
make test  # use test-v for verbose version of pytest
```

Force the Python code style guide/reformat all files (outside container):

```shell
make lint
```

For more commands check `make help`.


## Customizing environment variables

For each service we have a default environment file named `docker/env/<service>`. If you need to change any of the
default variables, create a file `docker/env/<service>.local` and put them there. This file will be ignored by Git and
docker compose will load it right after the default one (overwriting the values with your version).


## Backup

You may need to backup the following directories:
- `docker/data/web` in case your Web application stores user data in `/data` (or equivalent Dokku volume on production
  server)
- `docker/data/db` for the database (or equivalent Dokku volume on production server)


## Services

The services configured on Docker compose are:

- `web`: Django container, acessible through [localhost:5000](http://localhost:5000/)
- `db`: postgres container, without port forwarding from the host machine (you can connect `psql` to this database by
  running `docker compose exec web python manage.py dbshell`)
