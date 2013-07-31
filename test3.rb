require 'rbvmomi'

vim = RbVmomi::VIM.connect host: 'hostname',user: 'user', password: 'password', insecure: true
vm=vim.serviceInstance.find_datacenter.find_vm("Folder/tmpl-debian-6-64") or abort ("VM Not Found!")

xconfig=RbVmomi::VIM.VirtualMachineConfigSpec(:annotation => 'Notes : tada'+"\n" )

vm.ReconfigVM_Task(:spec => xconfig).wait_for_completion

print "Done ..."
