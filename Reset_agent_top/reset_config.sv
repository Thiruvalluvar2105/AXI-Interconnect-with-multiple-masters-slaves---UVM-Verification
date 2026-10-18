class reset_config extends uvm_object;
	`uvm_object_utils(reset_config)

	uvm_active_passive_enum is_active;
	
	//reset interface handle

	virtual reset_interface reset_vif;

	function new(string name="reset_config");
		super.new(name);
	endfunction

endclass

