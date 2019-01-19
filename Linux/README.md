# Linux tools for Webmaster or/and DevOps
## CloudFlare Proxy Disable Helper
### Usages
1. Set API Auth Key file location
..1. ```bash
-akf= //Location of the file containing the API Auth Key
```
..2. ```bash
--authkey_file= //same but longer
```
2. Set API Auth Key (as String)
..1. ```bash
-ak= //String of the API Auth Key
```
..2. ```bash
----authkey= //same
```
3. Set Email of CloudFlare account
..1. ```bash
-e= //Email
```
..2. ```bash
--email= //same
```
4. Set Script location of operations to do while the CloudFlare proxies are disabled
..1. ```bash
-ops= //location of script
```
..2. ```bash
--operations_script= //same
```
5. (WIP) Set silent mode of the script (May be useful for usage in a script), default false
..1. ```bash
-s //Set silent to true
```
..2. ```bash
--silent //same
```