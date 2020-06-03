cimport vmmapi
cimport cpuset
cimport types
cimport vmm

import enum
import os

from libc.errno cimport errno
from libc.stdlib cimport free


class Error(enum.IntEnum):
    OPEN_FAILED = 100
    STATS_FETCH_FAILED = 101
    RETRIEVE_ACTIVE_VCPU_FAILED = 102


class BhyveException(RuntimeError):
    def __init__(self, code, message):
        super(BhyveException, self).__init__(f'[Errorno {code}] {message}')
        self.code = code

cdef class VM:

    cdef str vm_name
    cdef vmmapi.vmctx *vm

    def __cinit__(self, str vm_name_p, bint create_vm=0):
        self.vm_name = vm_name_p
        vm_name_bytes = vm_name_p.encode()
        cdef char *vm_name = vm_name_bytes

        if create_vm:
            with nogil:
                code = vmmapi.vm_create(vm_name)

            if code != 0:
                raise BhyveException(
                    errno, f'Failed to create VM {self.vm_name} - {os.strerror(errno)}'
                )

        with nogil:
            self.vm = vmmapi.vm_open(vm_name)

        if self.vm == NULL:
            raise BhyveException(
                Error.OPEN_FAILED, f'Could not open VM {self.vm_name}'
            )

    def force_reset(self):
        with nogil:
            error = vmmapi.vm_suspend(self.vm, vmm.VM_SUSPEND_RESET)

        if error:
            raise BhyveException(
                errno, os.strerror(errno)
            )

        return True

    def force_poweroff(self):
        with nogil:
            error = vmmapi.vm_suspend(self.vm, vmm.VM_SUSPEND_POWEROFF)

        if error:
            raise BhyveException(
                errno, os.strerror(errno)
            )

        return True

    def get_stats(self, vcpu=None):
        active_vcpus = self.active_vcpus()
        if vcpu is not None and not -1 < vcpu < active_vcpus:
            raise BhyveException(
                Error.STATS_FETCH_FAILED, f'Please specify a vcpu number from 0-{active_vcpus}'
            )

        stats = {}
        if vcpu is None:
            for i in range(active_vcpus):
                stats[f'cpu_{i}'] = self.__get_stats(i)
        else:
            stats[f'cpu_{vcpu}'] = self.__get_stats(vcpu)

        return stats

    def __get_stats(self, int vcpu):
        # TODO: Should we be using vcpu count from 1-16 or 0-15 ? There are 2 perspectives to this
        # End user will expect something from 1 -16 and a dev from 0 - 15 as the underlying api uses this
        cdef vmmapi.timeval tv
        cdef int num_stats, i = 0
        cdef types.uint64_t *stats
        cdef const char *desc

        with nogil:
            stats = vmmapi.vm_get_stats(self.vm, vcpu, &tv, &num_stats)

        stat_list = []

        if stats != NULL:
            while i < num_stats:
                stat_list.append({
                    'description': vmmapi.vm_get_stat_desc(self.vm, i).decode(),
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
            vmmapi.vm_destroy(self.vm)

    def active_vcpus(self):
        cdef cpuset.cpuset_t cpus

        with nogil:
            error = vmmapi.vm_active_cpus(self.vm, &cpus)

        if not error:
            return [True for i in range(vmm.VM_MAXCPU) if cpuset.CPU_ISSET(i, &cpus)].count(True)
        else:
            raise BhyveException(
                Error.RETRIEVE_ACTIVE_VCPU_FAILED, 'Failed to retrieve active vcpu count'
            )

    def __dealloc__(self):
        free(self.vm)

    def __str__(self):
        return f'VM {self.vm_name}'

def seven():
    return 7

def get_vm(str name):
    return VM(name)
