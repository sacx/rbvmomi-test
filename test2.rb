#
# 
# Simple example to clone a machine from an template with spec created from pool
# Author:: Adrian Stanila
#
#
require 'rbvmomi'

#Code from knife-vsphere BaseVsphereCommand.rb, modified for current needs. 
#Code also can be simplified to look only for poolName directly, but this is not the point in this example
def find_pool(vim,poolName)
	dcname = nil
	dc = vim.serviceInstance.find_datacenter(dcname) or abort "datacenter not found"
	baseEntity = dc.hostFolder
	entityArray = poolName.split('/')
	entityArray.each do |entityArrItem|
		if entityArrItem != ''
			if baseEntity.is_a? RbVmomi::VIM::Folder
				baseEntity = baseEntity.childEntity.find { |f| f.name == entityArrItem } or abort "no such pool #{poolName} while looking for #{entityArrItem}"
			elsif baseEntity.is_a? RbVmomi::VIM::ClusterComputeResource
				baseEntity = baseEntity.resourcePool.resourcePool.find { |f| f.name == entityArrItem } or abort "no such pool #{poolName} while looking for #{entityArrItem}"
			elsif baseEntity.is_a? RbVmomi::VIM::ResourcePool
				baseEntity = baseEntity.resourcePool.find { |f| f.name == entityArrItem } or abort "no such pool #{poolName} while looking for #{entityArrItem}"
			else
				abort "Unexpected Object type encountered #{baseEntity.type} while finding resourcePool"
			end
		end
	end

        baseEntity = baseEntity.resourcePool if not baseEntity.is_a?(RbVmomi::VIM::ResourcePool) and baseEntity.respond_to?(:resourcePool)
        baseEntity
end


vim = RbVmomi::VIM.connect host: 'host',user: 'user', password: 'password', insecure: true
vm=vim.serviceInstance.find_datacenter.find_vm("Folder/template-debian-6-64") or abort ("VM Not Found!")

xconfig=RbVmomi::VIM.VirtualMachineConfigSpec(:annotation => 'Creation time:  ' + Time.now.strftime("%Y-%m-%d %H:%M") + "\n\n")

relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(:pool => find_pool(vim,'TEST'))
spec = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec, :powerOn => false, :template => false, :config => xconfig)

task = vm.CloneVM_Task(:folder => vm.parent, :name => "test-clone", :spec => spec)
print "Cloning ..."
task.wait_for_completion
