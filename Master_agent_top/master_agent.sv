class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)
	master_config master_cfg;
	master_driver master_drvh;
	master_monitor master_monh;
	master_sequencer master_seqrh;

	extern function new(string name="master_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass

	function master_agent :: new(string name="master_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void master_agent :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(master_config) :: get(this,"","master_config",master_cfg))
			`uvm_fatal("master_agent","getting config failed")


		master_monh=master_monitor::type_id::create("master_monh",this);
		if(master_cfg.is_active==UVM_ACTIVE)
		begin
			master_drvh=master_driver::type_id::create("master_drvh",this);
			master_seqrh=master_sequencer::type_id::create("master_seqrh",this);
		end
	endfunction

	function void master_agent::connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(master_cfg.is_active==UVM_ACTIVE)
		begin
			master_drvh.seq_item_port.connect(master_seqrh.seq_item_export);
		end

	endfunction


