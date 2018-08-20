cdef extern from "libvmmapi.h":
    extern int vm_create(const char *name)
