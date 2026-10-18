class reset_agent extends uvm_agent;
	`uvm_component_utils(reset_agent)
	reset_config reset_cfg;
	reset_driver reset_drvh;
	reset_monitor reset_monh;
	reset_sequencer reset_seqrh;

	extern function new(string name="reset_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass
	function  reset_agent :: new(string name="reset_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void reset_agent::  build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(reset_config) :: get(this,"","reset_config",reset_cfg))
			`uvm_fatal("reset_agent","getting config failed")


		reset_monh=reset_monitor::type_id::create("reset_monh",this);
		if(reset_cfg.is_active==UVM_ACTIVE)
		begin
			reset_drvh=reset_driver::type_id::create("reset_drvh",this);
			reset_seqrh=reset_sequencer::type_id::create("reset_seqrh",this);
		end
	endfunction
	
	function void reset_agent :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		reset_drvh.seq_item_port.connect(reset_seqrh.seq_item_export);
	endfunction

	

