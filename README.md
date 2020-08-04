# docker-compose-nginx-env-example

This repo demonstrates how to use an environment variable in `nginx`,
when you run `nginx` inside a Docker container with `docker-compose`.

In this example, `docker-compose` passes the `HOST` env to the `Dockerfile`
to build the container using:

```
build:
  args:
  - HOST
```

To make the `HOST` env variable available at run-time, `docker-compose` uses:

```
environment:
- HOST
```

In both cases, the `HOST` env is picked up by the `Dockerfile` using:

```
ARG HOST
```

The `Dockerfile` also overwrites the default `nginx` config file with our own:

```
ADD nginx.conf /etc/nginx/nginx.conf
```

By default, `nginx` doesn't allow env variables to be used, so we have to
make this explicit in `nginx.conf`:

```
env HOST;
```

For some reason, we can't use the env variable directly, but need to extract it
using one of the supported scripting languages (here: Perl):

```
load_module modules/ngx_http_perl_module.so;
perl_set $ext_hostname 'sub { return $ENV{"HOST"}; }';
```

This will make the `HOST` env available inside `nginx` as `$ext_hostname`,
e.g. with a directive like:

```
server {
    listen         80;
    location / {
        return 200 'HOST at run-time: ${ext_hostname}\n';
    }
}
```


# Usage examples

## docker build

To make the env variable `HOST` available at built-time, use:

```
$ docker build --build-arg HOST=example.com -t docker-nginx-env .
[...]
Step 6/6 : RUN echo "HOST at build-time: $HOST"
 ---> Running in ebb80aff9255
HOST at build-time: example.com
[...]
```

## docker run

The `HOST` env variable used at build-time is **not available** at run-time, though:

```
$ docker run -p 80:80 -d docker-nginx-env
5ce21faf4cebb35383af19171a4359c1449b1dff92c0552ef75143d24021ef22

$ curl localhost
HOST at run-time: 
```

If you want to set the `HOST` env variable inside `nginx` at Docker run-time, do this:

```
$ docker run -p 80:80 -d --env HOST=foo docker-nginx-env
710b70aef5edfd5b5ccc13e954f57e1d407a2156adea7b989d55678a247503be

$ curl localhost
HOST at run-time: foo
```


## docker-compose

With `docker-compose`, the `HOST` env is set like this:

```
$ HOST=foo docker-compose -f docker-compose.yml up --build --force-recreate
[...]
Step 6/6 : RUN echo "HOST at build-time: $HOST"
 ---> Running in d1f9023e2797
HOST at build-time: foo
```

This command will both build and run the container, so calling `nginx` works as expected:

$ curl localhost
HOST at run-time: foo

