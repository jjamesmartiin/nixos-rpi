# Full process 
## building the image
1. Clone the repository:
    ```
    git clone git@github.com:jjamesmartiin/nixos-raspberrypi.git
    ```
2. Edit the `flake.nix` file to include your SSH public key:
    - edit the line that says `# your ssh pub key here` and replace it with your actual public key.
3. Build the image:
    ``` 
    nix build .#installerImages.rpi5
    ```
    - press 'y' to everything
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
- [ ] once the image is built then how do we flash it to the micro sd card? 
1. read the `result` and decompress the image: 
    ```
    zstd --decompress result/sd-image/nixos-installer-rpi5-kernel.img.zst -o ./nixos-rpi-image
    ```
2. Flash the nixos-rpi-image with rpi-imager (only working on windows, can't find any file on linux)
3. Boot 

## build and deploy 
build it with:
```
export SYSTEM="rpi-test"
nix-build
```


 
deploy it with
```
./build-and-deploy.sh -s $SYSTEM
```


