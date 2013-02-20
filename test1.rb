require 'rbvmomi'

vim = RbVmomi::VIM.connect host: 'hostname',user: 'user', password: 'password', insecure: true
vm=vim.serviceInstance.find_datacenter.find_vm("Folder/tmpl-debian-6-64") or abort ("VM Not Found!")

VIM = RbVmomi::VIM
relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec

spec = VIM.VirtualMachineCloneSpec(:location => relocateSpec, :powerOn => false, :template => false)
task = vm.CloneVM_Task(:folder => vm.parent, :name => "test-clone", :spec => spec)
print "Cloning ..."
task.wait_for_completion