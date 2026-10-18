class reset_driver extends uvm_driver #(reset_xtn);
	`uvm_component_utils(reset_driver)
	reset_config reset_cfg;
	//virtual interface handle
	
	virtual reset_interface.RST_DRV_MP reset_vif;
	
	extern function new(string name="reset_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass

	function reset_driver :: new(string name="reset_driver",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void reset_driver :: build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(reset_config) :: get(this,"","reset_config",reset_cfg))
			`uvm_fatal("reset_driver","getting cojnfig failed")
	
	endfunction

	function void reset_driver :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		reset_vif=reset_cfg.reset_vif;
	endfunction

	task reset_driver :: run_phase(uvm_phase phase);
		
		@(reset_vif.rst_drv_cb);
		reset_vif.rst_drv_cb.reset<=1'b1;
		@(reset_vif.rst_drv_cb);
		reset_vif.rst_drv_cb.reset<=1'b0;
	endtask

