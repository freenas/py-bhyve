# py-bhyve

![Python Version](https://img.shields.io/badge/Python-3.6-blue.svg)

## A wrapper for libvmmapi

py-bhyve is a wrapper to encapsulate the functionality of libvmmapi.

## Installation

### GitHub:


The FreeBSD source tree ***must*** be located at `$FREEBSD_SRC` (`/usr/src` by default) to build from git on BSD.

- `python setup.py build_ext -i && python setup.py install --user`

The Illumos source tree ***must*** be located at `$ILLUMOS_SRC` to build from git for Illumos. Please point to the `usr/src` subdirectory (to match the behaviour with BSD)
  - For illumos-gate sources, use `setup.illumos.py`
  - For illumos-omnios sources, use `setup.omnios.py`
It is likely that the module will compile correctly when using either tree, but the organisation of these differs and so we need to set different search paths. If you have no reason not to, it is recommended to clone the version for your specific OS.
```
export ILLUMOS_SRC=....
python3 setup.illumos.py build_ext -i # or setup.omnios.py, ...
python3 setup.illumos.py install --user # or sudo/pfexec setup.illumos.py install
```

## QUICK HOWTO

`import bhyve`

Get a running VM:

`vm = bhyve.get_vm('foo')`

Fetch stats for a vm:

`vm.get_stats()`

This will return a dictionary of active vcpu's with their respective stats.

Get help:

`help(bhyve.VM)`
