# Setting Up the Intel C compiler

- Intel has recently released a new framework for softwae development tools `Intel oneAPI Toolkit` (https://software.intel.com/content/www/us/en/develop/tools/oneapi.html)
- Unlike previous versions it doesn't require any license and is free for commercial use as well. 

## Steps to install

1. If you have proxy set up: 

```
  $ export http_proxy=http://<user>:<pass>@proxy.<server>.com:<port>
  $ export https_proxy=https://<user>:<pass>@proxy.<server>.com:<port>
  $ export HTTP_PROXY=${http_proxy}
  $ export HTTPS_PROXY=${https_proxy}
```


2. Set up your package manager to use the Intel repository:
  - Get the Intel Repository public key and install it. The example below uses /tmp

```
     $ cd /tmp
     $ wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
     $ sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
     $ rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
```

  - Configure the APT client to use Intel's repository:

```
     $ echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
     $ sudo apt-get update
```


3. Install  the required package

```
   $ sudo apt-get install intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
```


4. Configute the compiler. If code gen for 32 bit architecture pass `ia32` argument as well while configuring.

```
   $ source /opt/intel/oneapi/setvars.sh        # If configuration for 64-bit arch
   $ source /opt/intel/oneapi/setvars.sh ia32   # If configuration for 32-bit arch
```


5. Path of the intalled compiler:

```
   $ which icpc
   /opt/intel/oneapi/compiler/2021.2.0/linux/bin/intel64/icpc
```


