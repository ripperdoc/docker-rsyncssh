# ssh+rsync Docker image

Once configured to accept one or more ssh keys, it will permit one to use rsync+ssh to store data or to read data to/from the docker container.

The container is exporting:
* port 22 (for ssh connections)
* `/data` volume

## Build image

```
docker build --rm -t ssh-rsync-image .
```

## Run the container

* First you need to create at least one ssh key (without passphrase)

```
ssh-keygen -t rsa -f ~/.ssh/id_rsa_rsync -N ''
```

* Run the container:

```
docker run -itdP -p 22222:22 -v ~/data:/data -e AUTHORIZED_KEYS="rw:`cat ~/.ssh/id_rsa_rsync.pub`" --name ssh-rsync-server ssh-rsync-image
```

* Check logs:

```
docker logs ssh-rsync-server 
```

## Use

* Rsync local `/etc` to remote `/data/etc` (note: all paths are always relative to `/data`)

```
rsync -av -e "ssh -i $HOME/.ssh/id_rsa_rsync -p 22222" /etc root@127.0.0.1:/
```


## About authorized keys:

* each key has to be prefixed by rw: or ro:, repectively for read+write access or read-only access
* multiple keys can be specified, separated by "," (commas)

Exemple: `AUTHORIZED_KEYS="rw:myfirstkey, ro:mysecondkey"`



Inspired by:
* https://github.com/tutumcloud/authorizedkeys
* https://github.com/Thrilleratplay/docker-ssh-rsync
* https://www.guyrutenberg.com/2014/01/14/restricting-ssh-access-to-rsync/

