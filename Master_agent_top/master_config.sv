class master_config extends uvm_object;
	`uvm_object_utils(master_config)

	uvm_active_passive_enum is_active;
	
	//master interface handle

	virtual axi_master_interface master_vif;

	function new(string name="master_config");
		super.new(name);
	endfunction

endclass
