from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import os


try:
    from Cython.Distutils import build_ext
    from Cython.Distutils.extension import Extension
except ImportError:
    raise ImportError('This package requires Cython to build properly. Please install it first.')


if 'FREEBSD_SRC' not in os.environ:
    os.environ['FREEBSD_SRC'] = '/usr/src/'


system_includes = [
    #'${FREEBSD_SRC}/lib/libvmm',
    '/usr/src/lib/libvmmapi',
]

system_includes = [os.path.expandvars(x) for x in system_includes]
print(system_includes)


setup(
    name='bhyve',
    version='1.0.0',
    cmdclass={'build_ext': build_ext},
    ext_modules=[
        Extension(
            'bhyve',
            ['bhyve.pyx'],
            libraries=['vmmapi'],
            cython_include_dirs=['./pxd'],
            include_dirs=system_includes
        )
    ]
)
