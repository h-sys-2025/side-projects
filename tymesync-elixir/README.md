## TymeSync -- whatever time syncing webapi!

### 404:
```sh
_*_ Running: `curl 127.0.0.1:4000/whatever` _*_


{"error":"NOT FOUND\navalable pages:\n\t1. /time --- know my time.\n\t2. /sync <your_time> ---- lets
sync our times."}

Process completed with exit code: 0
```

### know my time:
```sh
_*_ Running: `curl 127.0.0.1:4000/time` _*_


{"message":"2026-07-25 06:23:06.065385Z"}

Process completed with exit code: 0
```

## lets sync our times:
```sh
_*_ Running: `curl 127.0.0.1:4000/sync -d '{"my-time":"12345"}'` _*_


{"message":"debug: sorry, timesync is not yeat implemented!"}

Process completed with exit code: 0
```

### sus:
```sh
_*_ Running: `curl 127.0.0.1:4000/sync -d '{"12345!@#$%qwert":"ls -la"}'` _*_


{"message":"0\ntotal 24\ndrwxr-xr-x  2 dzebra dzebra 4096 Jul 25 11:21 .\ndrwxrwxr-x 26 dzebra dzebra
 4096 Jul 24 20:03 ..\n-rw-------  1 dzebra dzebra  300 Jul 25 11:21 README.md\n-rw-r--r--  1 dzebra
dzebra  300 Jul 25 11:21 README.md.backup\n-rw-------  1 dzebra dzebra 1931 Jul 24 18:21 tymesync.exs
\n-rw-r--r--  1 dzebra dzebra 1931 Jul 24 18:21 tymesync.exs.backup\n"}

Process completed with exit code: 0
```