# Homework 10

before

```
cpu0: starting 0
sb: size 1000 nblocks 941 ninodes 200 nlog 30 logstart 2 inodestart 32 bmap start 58
init: starting sh
$ big
.
wrote 140 sectors
done; ok
```

after 

```
cpu0: starting 0
sb: size 20000 nblocks 19937 ninodes 200 nlog 30 logstart 2 inodestart 32 bmap start 58
init: starting sh
$ big
.....................................................................................................................................................................
wrote 16523 sectors
done; ok
$
```