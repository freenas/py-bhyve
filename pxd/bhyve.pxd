cimport vmm


cdef extern from 'vmmapi.h' nogil:
    cdef struct vmctx:
        pass

    cdef struct timeval:
        pass

    extern int vm_create(const char *name)
    extern vmctx *vm_open(const char *name)
    extern void	vm_destroy(vmctx *ctx)
    extern int *vm_get_stats(vmctx *ctx, int vcpu, timeval *ret_tv, int *ret_entries)
    extern const char *vm_get_stat_desc(vmctx *ctx, int index)
    extern int	vm_suspend(vmctx *ctx, vmm.vm_suspend_how how)
