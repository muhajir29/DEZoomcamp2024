# Remote VM GPC in Visual Studio

in windows, we recoment using git bash

1. open git bash
2. create folder with name .ssh

    ```console
    mkdir .ssh
    cd .ssh
    ```

3. Create SSH key pair

    <https://cloud.google.com/compute/docs/connect/create-ssh-keys?hl=en#linux-and-macos>

    ```console
    ssh-keygen -t rsa -f gcp -C imam -b 2048
    ```

4. Add ssh key to gcp compute engine

    a. Open SSH key public

    ```console
    cat gcp.pub
    ```

    and copy the result

    b. Go to Meta Data in Compute Engine

    <https://console.cloud.google.com/compute/metadata?project=<my project id>>

    c. Add keys

    and paste key from gcp.pub

5. Try connect VM from local

    ```console
    ssh -i gcp imam@35.203.104.61
    ```

6. Save config Credential

    a. Create config file

    ```console
        cd .ssh
        touch config
        code config
    ```

    b. add credential in config file

    format:

    ```config
    Host <remote name>
        HostName <IP Address External>
        User <user>
        IdentityFile <path credentiala>
    ```

    ```config
    Host de-zoomcamp
        HostName 35.203.104.61
        User imam
        IdentityFile c:/Users/imamm/.ssh/gcp
    ```

7. Remote Using Visual Studio code

    a. Open Visual Studio Code

    b. Install extection

    Install Extention "Remote SSH" by "Microsoft"

    c. Connect

    - Push F1
    - Search remote-ssh:Connect-to-host
    - choice de-zoomcamp

8. Shotdown vm

    ```console
    sudo shotdown now
    ```
