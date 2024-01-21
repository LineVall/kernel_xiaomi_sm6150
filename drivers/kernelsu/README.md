
# KernelSU
* A fork of https://github.com/tiann/KernelSU.git by @tiann

## Installing as a part of the kernel

1. Let's take [linux] as the path to your kernel source dir.
```
        cd [linux]
        git clone https://github.com/itsshashanksp/KernelSU.git
	cp -ar KernelSU [linux]/drivers/kernelsu
```

2. edit [linux]/drivers/Kconfig
```
	+source "drivers/kernelsu/Kconfig"
```

3. edit [linux]/drivers/Makefile
```
	+obj-$(CONFIG_KSU)	+= kernelsu/
```

4. Here you can find the guide for adding KSU hooks for non GKI kernels.

*  https://kernelsu.org/guide/how-to-integrate-for-non-gki.html

5. set KSU defconfig
```
#
# KernelSU
#
CONFIG_KSU=y
# CONFIG_KSU_DEBUG is not set
```

build your kernel

* For more information or any doubt visit official website of KernelSU https://kernelsu.org/
