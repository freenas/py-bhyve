cdef extern from "libvmmapi/libvmmapi.h":
    extern int vm_create(const char *name)
