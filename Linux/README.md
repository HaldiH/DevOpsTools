# Linux tools for Webmaster or/and DevOps
## CloudFlare Proxy Disable Helper
### Usages
1. Set API Auth Key file location
1.1.
```shell
-akf= *Location of the file containing the API Auth Key*
```
1.2.
```shell
--authkey_file= *same but longer*
```
2. Set API Auth Key (as String)
2.1. 
```shell
-ak= *String of the API Auth Key*
```
2.2. 
```shell
----authkey= *same*
```
3. Set Email of CloudFlare account
3.1. 
```shell
-e= *Email*
```
3.2. 
```shell
--email= *same*
```
4. Set Script location of operations to do while the CloudFlare proxies are disabled
4.1. 
```shell
-ops= *location of script*
```
4.2. 
```shell
--operations_script= *same*
```
5. (WIP) Set silent mode of the script (May be useful for usage in a script), default false
5.1. 
```shell
-s *Set silent to true*
```
5.2. 
```shell
--silent *same*
```