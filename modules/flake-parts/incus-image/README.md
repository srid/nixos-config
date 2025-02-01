To build the image,

```sh
nix run .#incus-image-container-import public-container
```

To launch a container using it,

```sh
incus launch srid/public-container --ephemeral test
```

`public-container` runs nginx serving Hello world, which can test if the container is working.

```sh
# Find the IP
❯ incus list
+------+---------+----------------------+-----------------------------------------------+-----------------------+-----------+
| NAME |  STATE  |         IPV4         |                     IPV6                      |         TYPE          | SNAPSHOTS |
+------+---------+----------------------+-----------------------------------------------+-----------------------+-----------+
| test | RUNNING | 10.162.27.156 (eth0) | fd42:ef6e:8271:3b9f:216:3eff:fea2:b8a6 (eth0) | CONTAINER (EPHEMERAL) | 0         |
+------+---------+----------------------+-----------------------------------------------+-----------------------+-----------+

# curl container's nginx
❯ curl 10.162.27.156
Hello World%
```
