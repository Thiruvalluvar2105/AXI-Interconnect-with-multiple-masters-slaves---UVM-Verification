class slave_config extends uvm_object;
	`uvm_object_utils(slave_config)

	uvm_active_passive_enum is_active;
	
	//slave interface handle

	virtual axi_slave_interface slave_vif;

	function new(string name="slave_config");
		super.new(name);
	endfunction

endclass
