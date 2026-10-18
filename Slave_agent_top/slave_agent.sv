class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)
	slave_config slave_cfg;
	slave_driver slave_drvh;
	slave_monitor slave_monh;
	slave_sequencer slave_seqrh;

	extern function new(string name="slave_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass

	function slave_agent :: new(string name="slave_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void slave_agent :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(slave_config) :: get(this,"","slave_config",slave_cfg))
			`uvm_fatal("slave_agent","getting config failed")


		slave_monh=slave_monitor::type_id::create("slave_monh",this);
		if(slave_cfg.is_active==UVM_ACTIVE)
		begin
			slave_drvh=slave_driver::type_id::create("slave_drvh",this);
			slave_seqrh=slave_sequencer::type_id::create("slave_seqrh",this);
		end
	endfunction

	function void slave_agent::connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(slave_cfg.is_active==UVM_ACTIVE)
		begin
			slave_drvh.seq_item_port.connect(slave_seqrh.seq_item_export);
		end

	endfunction



