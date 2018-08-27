cimport bhyve
cimport types
cimport vmm

import enum

from libc.errno cimport errno
from libc.stdlib cimport free


class Error(enum.IntEnum):
    OPEN_FAILED = 1
    STATS_FETCH_FAILED = 2


class BhyveException(RuntimeError):
    def __init__(self, code, message):
        super(BhyveException, self).__init__(f'[Errorno {code}] {message}')
        self.code = code

cdef class VM:

    cdef str vm_name
    cdef bhyve.vmctx* vm

    def __cinit__(self, str vm_name_p, bint create_vm=0):
        self.vm_name = vm_name_p
        vm_name_bytes = vm_name_p.encode()
        cdef char* vm_name = vm_name_bytes

        if create_vm:
            with nogil:
                code = bhyve.vm_create(vm_name)

            if code != 0:
                raise BhyveException(
                    errno, f'Failed to create VM {self.vm_name}'
                )

        with nogil:
            self.vm = bhyve.vm_open(vm_name)

        if self.vm == NULL:
            raise BhyveException(
                Error.OPEN_FAILED, f'Could not open VM {self.vm_name}'
            )

    def force_reset(self):
        with nogil:
            error = bhyve.vm_suspend(self.vm, vmm.VM_SUSPEND_RESET)

        if error:
            raise BhyveException(
                errno, f'Could not force reset'
            )

        return True

    def force_poweroff(self):
        with nogil:
            error = bhyve.vm_suspend(self.vm, vmm.VM_SUSPEND_POWEROFF)

        if error:
            raise BhyveException(
                errno, f'Could not force poweroff'
            )

        return True

    def get_stats(self, int vcpu=0):
        cdef bhyve.timeval tv
        cdef int num_stats, i = 0
        cdef types.uint64_t *stats
        cdef const char *desc

        with nogil:
            stats = bhyve.vm_get_stats(self.vm, vcpu, &tv, &num_stats)

        stat_list = []

        if stats != NULL:
            while i < num_stats:
                stat_list.append({
                    'description': bhyve.vm_get_stat_desc(self.vm, i).decode(),
                    'value': stats[i]
                })
                i += 1
        else:
            raise BhyveException(
                Error.STATS_FETCH_FAILED, 'Failed to fetch stats'
            )

        return stat_list

    def destroy(self):
        with nogil:
            bhyve.vm_destroy(self.vm)

    def __dealloc__(self):
        free(self.vm)

    def __str__(self):
        return f'VM {self.vm_name}'


def get_vm(str name):
    return VM(name)
