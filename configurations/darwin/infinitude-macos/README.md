## Tart VM CI

### Creating the VM

https://tart.run/

- `tart clone` the macOS VM
- `tart create` it 
- `tart set` disk size and mem
    ```
    tart set infinitude-macos --cpu 6 --memory 16000 --disk-size 500
    ```
- `tart run` it

## Deploying

```
just activate infinitude-macos
```

## GitHub Runners

I use this VM on demand. It is off by default. When I need macOS CI, I start it with `tart run`. It seems GitHub runners get stuck across the host macOS suspend cycle; so it is better just shutdown/restart the VM.