from distutils.core import setup
import os


try:
    from Cython.Distutils import build_ext
    from Cython.Distutils.extension import Extension
except ImportError:
    raise ImportError('This package requires Cython to build properly. Please install it first')


if 'ILLUMOS_SRC' not in os.environ:
    #os.environ['ILLUMOS_SRC'] = '/usr/src'
    print("Error: ILLUMOS_SRC must point towards the illumos-gate source tree (and usr/src inside that)")
    exit(1)

try:
    os.symlink('/lib/amd64/libvmmapi.so.1', './libvmmapi.so')
except FileExistsError:
    pass


# There doesn't seem to be any way to get both Cython and the linker to see the
# library at version 1; explicit linker flags cause Cython to miss the library and
# we have missing symbols, with ldd showing the library wasn't ever asked for
# Conversely the documentation here:
# https://python.readthedocs.io/en/stable/distutils/apiref.html#distutils.core.Extension
# requires a library name, not path, and this will cause the linker to fail as 
# we have libvmmapi.so.1 and not libvmmapi.so, but which does mean the library is
# found and linked in.
# A really hacky solution is just to symlink to the required file and add the
# pwd ot the search path; this hopefully shouldn't carry through to runtime and
# the output according to ldd is linked up correctly to /lib/amd64/libvmmapi.so.1

system_includes = [
   '${ILLUMOS_SRC}/compat/bhyve',
   '${ILLUMOS_SRC}/uts/i86pc', 
   '${ILLUMOS_SRC}/lib/libvmmapi/common/',
   '${ILLUMOS_SRC}/compat/bhyve/amd64/machine/',
   '${ILLUMOS_SRC}/../contrib/bhyve/amd64/',
   '${ILLUMOS_SRC}/contrib/bhyve/amd64',
   '${ILLUMOS_SRC}/compat/bhyve/amd64'
]

system_includes = [os.path.expandvars(x) for x in system_includes]

setup(
    name='bhyve',
    version='1.0.0',
    cmdclass={'build_ext': build_ext},
    ext_modules=[
        Extension(
            'bhyve',
            ['bhyve.pyx'],
            libraries=['vmmapi'],
            library_dirs=['/lib/amd64', '.'],
            cython_include_dirs=['./pxd'],
            include_dirs=system_includes
        )
    ]
)
