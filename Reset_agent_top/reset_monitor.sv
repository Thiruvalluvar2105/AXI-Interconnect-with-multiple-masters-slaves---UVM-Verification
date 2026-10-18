class reset_monitor extends uvm_monitor;
	`uvm_component_utils(reset_monitor)
	reset_config reset_cfg;
	reset_xtn xtn;
	uvm_analysis_port#(reset_xtn) reset_ap;

	//virtual interface handle
	virtual reset_interface.RST_MON_MP reset_vif;
		
	extern function new(string name="reset_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass

	function reset_monitor :: new(string name="reset_monitor",uvm_component parent);
		super.new(name,parent);
		reset_ap=new("reset_ap",this);
		
	endfunction


	function void reset_monitor :: build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(reset_config) :: get(this,"","reset_config",reset_cfg))
			`uvm_fatal("reset_monitor","getting cojnfig failed")
	
	endfunction

	function void reset_monitor :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		reset_vif=reset_cfg.reset_vif;
	endfunction

	task reset_monitor :: run_phase(uvm_phase phase);
	repeat(2)
		begin
		xtn=reset_xtn::type_id::create("xtn");		
		
		@(reset_vif.rst_mon_cb);

		xtn.reset=reset_vif.rst_mon_cb.reset;
		reset_ap.write(xtn);
		end
		
	endtask

