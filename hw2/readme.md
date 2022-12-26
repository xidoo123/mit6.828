# Homework 2

### Question

child inherits parent fd, each fd points to the same IO object in kernel, so when closing one fd in parent, it's closed in child too

but why closing one fd in child, it doesn't affect parent??


### Answer

file description and file descriptor are not the same thing.

* When `fork`, child copy the whole file descriptors set of parent, but use the same file description as parent.

* Also, each file description has a count. When `close`, system remove the relation of the file description and file descriptor, then count -= 1. Only when the count == 0 will the file description and vnode be removed from kernel.

So both child and parent processes are not affected by each other when closing fd, but the offset (stored in file description) do share between them when calling `lseek` or smth.


```
man fork

      *  The child inherits copies of the parent's set of open file
      descriptors.  Each file descriptor in the child refers to the same
      open file description (see open(2)) as the corresponding file
      descriptor in the parent.  This means that the two file
      descriptors share open file status flags, file offset, and signal-
      driven I/O attributes (see the description of F_SETOWN and
      F_SETSIG in fcntl(2)).
```

Also, check CSAPP page 636.

