cdef extern from 'sys/cpuset.h' nogil:
    ctypedef unsigned long cpuset_t
    extern bint CPU_EMPTY(cpuset_t *cpuset)
    extern bint CPU_ISSET(size_t cpu_idx, cpuset_t *cpuset)
