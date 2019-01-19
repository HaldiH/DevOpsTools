# Linux tools for Webmaster or/and DevOps
## CloudFlare Proxy Disable Helper
### Usages
1. Set API Auth Key file location
    Location of the file containing the API Auth Key
    ```shell
    -akf=
    ```
    Same but longer
    ```shell
    --authkey_file=
    ```
2. Set API Auth Key (as String)
    String of the API Auth Key
    ```shell
    -ak=
    ```
    Or
    ```shell
    --authkey=
    ```
3. Set Email of CloudFlare account
    ```shell
    -e=
    ```
    Or
    ```shell
    --email=
    ```
4. Set Script location of operations to do while the CloudFlare proxies are disabled
    ```shell
    -ops=
    ```
    Or
    ```shell
    --operations_script=
    ```
5. (WIP) Set silent mode of the script to **true** (May be useful for usage in a script), default **false**
    ```shell
    -s
    ```
    Or
    ```shell
    --silent
    ```