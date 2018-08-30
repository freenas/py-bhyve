cdef extern from 'vmm.h' nogil:
    cpdef extern enum vm_suspend_how:
        VM_SUSPEND_RESET,
        VM_SUSPEND_POWEROFF
    cpdef extern int VM_MAXCPU
