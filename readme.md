# Full process 
## building the image
1. Clone this repo
    ```
    git clone git@github.com:jjamesmartiin/nixos-rpi.git
    ```
3. Build the image:
    ``` 
    ./build-image.sh # set a 5 min timer
    ```
    - This uses the binary cache to speed up the build (should take ~5 minutes).
    - if you have issues see the common troubleshooting below: 
        - **cross compilation issues:**
            ```
            boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" "armv6l-linux" ];
            ```
            - now when you try to build the image again, it should compile correctly.
        - **missing flakes:** 
            ```
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            ```
        - **not in the trusted users:**
            ```
            nix.settings.trusted-users = [ "jamesm" "root" ]; # replace 'jamesm' with your user
            ```

## flashing the image
1. read the `result` and decompress the image: 
    ```
    zstd --decompress result/sd-image/nixos-image-rpi5-kernel.img.zst -o ./nixos-rpi-image.img
    ```
2. Flash the nixos-rpi-image with rpi-imager or dd 
    - dd commands:
    ```
    lsblk
    DISKTOFLASH="/dev/sdX" # replace sdX with your micro sd card
    sudo dd if=./nixos-rpi-image.img of=$DISKTOFLASH bs=4M status=progress oflag=direct # set a 5 min timer
                                                                                      # it should be just over that ~313.543 seconds.

    sudo eject $DISKTOFLASH
    ```
3. Boot and login with username: `nixos` and password: `a`


## build and deploy 
build the configuration with:
```
export SYSTEM="rpi-test"
nix-build
```

change what you want in [systems/rpi-test/default.nix](systems/rpi-test/default.nix)

 
deploy it with
```
./build-and-deploy.sh -s $SYSTEM -t [whatever IP your system is on]

# or type it manually, you can omit the -t flag if you have DNS or a hosts file
./build-and-deploy.sh -s rpi-test
```


