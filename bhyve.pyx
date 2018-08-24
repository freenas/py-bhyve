cimport bhyve
cimport types
cimport vmm

import enum


class Error(enum.IntEnum):
    SUCCESS = 0
    OPEN_FAILED = -1


class BhyveException(RuntimeError):
    def __init__(self, code, message):
        super(BhyveException, self).__init__(message)
        self.code = code

cdef class VM:

    cdef str vm_name
    cdef bhyve.vmctx* vm

    def __cinit__(self, str vm_name, bint create_vm=0):
        self.vm_name = vm_name

        if create_vm:
            bhyve.vm_create(vm_name.encode())
            print('vm has been created ', vm_name)

        self.vm = bhyve.vm_open(vm_name.encode())
        if self.vm == NULL:
            raise BhyveException(
                Error.OPEN_FAILED, f'Could not open vm {vm_name}'
            )

    def force_reset(self):
        error = bhyve.vm_suspend(self.vm, vmm.VM_SUSPEND_RESET)
        if error:
            raise BhyveException(
                error, f'Error occurred with code: {error}'
            )

        return True

    def force_poweroff(self):
        error = bhyve.vm_suspend(self.vm, vmm.VM_SUSPEND_POWEROFF)
        if error:
            raise BhyveException(
                error, f'Error occurred with code: {error}'
            )

        return True

    def get_stats(self, int vcpu=0):
        cdef bhyve.timeval tv
        cdef int num_stats, i = 0
        cdef types.uint64_t *stats
        cdef const char *desc
        # TODO: Refine the code
        # TODO: Check for undefined behavior with different scenarios
        # TODO: Implement this in middlewared and make sure there is no undefined behaviour
        # TODO: Add detailed error logging
        stats = bhyve.vm_get_stats(self.vm, vcpu, &tv, &num_stats)
        stat_list = []

        if stats != NULL:
            while i < num_stats:
                stat_list.append({
                    'description': bhyve.vm_get_stat_desc(self.vm, i).decode(),
                    'value': stats[i]
                })
                i += 1

        return stat_list

    def destroy(self):
        bhyve.vm_destroy(self.vm)
        print('destroyed vm - ', self.vm_name)


def get_vm(str name):
    return VM(name)
