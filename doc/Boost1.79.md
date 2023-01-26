# Uninstalling existing Boost libraries 

In the following instructions, we assume that the existing Boost library is v1.71
```
$ sudo apt purge libboost1.71-dev
$ sudo apt purge libboost1.71-tools-dev

```

# Setting Up Boost 1.79

```
  $ git clone https://github.com/compilerai/tars /path/to/tars
  $ make -C /path/to/tars
  $ cd /tmp
  $ tar xf /path/to/tars/boost_1_79_0.tar.bz2
  $ ./bootstrap.sh
  $ sudo ./b2 install
```
