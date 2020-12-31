# Setting up compiler.ai server

Add the following line to /etc/sudoers
```
Defaults env_keep += "ftp_proxy http_proxy https_proxy no_proxy"
```

Add the special user
```
make add_compilerai_server_user
```

Install compilerai server
```
make install_compilerai_server
```

Start compilerai server
```
make start_compilerai_server
```

Stop compilerai server
```
make stop_compilerai_server
```
