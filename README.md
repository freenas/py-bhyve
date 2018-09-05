# py-bhyve

![Python Version](https://img.shields.io/badge/Python-3.6-blue.svg)

## A wrapper for libvmmapi

py-bhyve is a wrapper to encapsulate the functionality of libvmmapi.

## Installation

### GitHub:

The FreeBSD source tree ***must*** be located at `$SRC_BASE` (`/usr/src` by default) to build from git.

- `python setup.py build_ext -i && python setup.py install --user`

## FEATURES

- Ease of use
- Pythonic access to libvmmapi calls
- Retrieving stats for vm's

----

## QUICK HOWTO

`import bhyve as b`

Get a running VM:

`vm = b.get_vm('foo')`

Fetch stats for a vm:

`vm.get_stats()`

This will return a dictionary of active vcpu's with their respective stats.

Get help:

`help(bhyve.VM)`
