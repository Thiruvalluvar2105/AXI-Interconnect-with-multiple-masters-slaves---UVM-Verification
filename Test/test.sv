class base_test extends uvm_test;
	`uvm_component_utils(base_test)

	function new(string name="base_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	master_config master_cfg[];
	slave_config slave_cfg[];
	reset_config reset_cfg[];

	bit has_master_agent=1;
	bit has_slave_agent=1;
	bit has_scoreboard=1;
	bit has_reset_agent=1;

	int no_of_master_agents=2;//2
	int no_of_slave_agents=3;//3
	int no_of_reset_agents=1;

	env_config env_cfg;
	env env_h;
	master_sequence mast_seq;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_cfg=env_config::type_id::create("env_cfg");
		if(has_master_agent)
		begin
			master_cfg=new[no_of_master_agents];
			env_cfg.master_cfg=new[no_of_master_agents];

			foreach(master_cfg[i])
			begin
				master_cfg[i]=master_config::type_id::create($sformatf("master_cfg[%0d]",i));
				if(!uvm_config_db #(virtual axi_master_interface)::get(this,"",$sformatf("axi_mif_%0d",i),master_cfg[i].master_vif))
				begin
					`uvm_fatal("test","getting virtual interface in test got failed")
				end
				master_cfg[i].is_active=UVM_ACTIVE;
				env_cfg.master_cfg[i]=master_cfg[i];
			end
		end

		if(has_slave_agent)
		begin
			slave_cfg=new[no_of_slave_agents];
			env_cfg.slave_cfg=new[no_of_slave_agents];

			foreach(slave_cfg[i])
			begin
				slave_cfg[i]=slave_config::type_id::create($sformatf("slave_cfg[%0d]",i));
				if(!uvm_config_db #(virtual axi_slave_interface)::get(this,"",$sformatf("axi_sif_%0d",i),slave_cfg[i].slave_vif))
				begin
					`uvm_fatal("test","getting virtual interface in test got failed")
				end

				slave_cfg[i].is_active=UVM_ACTIVE;
				env_cfg.slave_cfg[i]=slave_cfg[i];
			end
		end
	
		if(has_reset_agent)
		begin
			reset_cfg=new[no_of_reset_agents];
			env_cfg.reset_cfg=new[no_of_reset_agents];

			foreach(reset_cfg[i])
			begin
				reset_cfg[i]=reset_config::type_id::create($sformatf("reset_cfg[%0d]",i));
				if(!uvm_config_db #(virtual reset_interface)::get(this,"","reset_interface",reset_cfg[i].reset_vif))
				begin
					`uvm_fatal("test","getting virtual interface in test got failed")
				end

				reset_cfg[i].is_active=UVM_ACTIVE;
				env_cfg.reset_cfg[i]=reset_cfg[i];
			end
		end

		env_cfg.has_master_agent=has_master_agent;
		env_cfg.has_slave_agent=has_slave_agent;
		env_cfg.has_scoreboard=has_scoreboard;
		env_cfg.has_reset_agent=has_reset_agent;

		env_cfg.no_of_master_agents=no_of_master_agents;
		env_cfg.no_of_slave_agents=no_of_slave_agents;
		env_cfg.no_of_reset_agents=no_of_reset_agents;

		uvm_config_db#(env_config)::set(this,"*","env_config",env_cfg);
		
		env_h=env::type_id::create("env_h",this);

	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology;
	endfunction

	task run_phase(uvm_phase phase);
		mast_seq=master_sequence::type_id::create("mast_seq");
		phase.raise_objection(this);
		for(int i=0;i<no_of_master_agents;i++)
		begin
				mast_seq.start(env_h.master_top.master_agth[i].master_seqrh);
		end
		#1000;
		phase.drop_objection(this);
	endtask


endclass


class fixed_test extends base_test;
	`uvm_component_utils(fixed_test)
	
	fixed_sequence_mast_0 fixed_seq_0;
	fixed_sequence_mast_1 fixed_seq_1;

	function new(string name="fixed_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
//		super.run_phase(phase);
		fixed_seq_0=fixed_sequence_mast_0::type_id::create("fixed_seq_0");
		fixed_seq_1=fixed_sequence_mast_1::type_id::create("fixed_seq_1");
		
		phase.raise_objection(this);
			fork
			fixed_seq_0.start(env_h.master_top.master_agth[0].master_seqrh);
			fixed_seq_1.start(env_h.master_top.master_agth[1].master_seqrh);
			join
			#1000;
		phase.drop_objection(this);
	endtask
endclass

class increment_test extends base_test;
	`uvm_component_utils(increment_test)
	
	increment_sequence_mast_0 incr_seq_0;
	increment_sequence_mast_1 incr_seq_1;

	function new(string name="increment_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
//		super.run_phase(phase);
		incr_seq_0=increment_sequence_mast_0::type_id::create("incr_seq_0");
		incr_seq_1=increment_sequence_mast_1::type_id::create("incr_seq_1");
		
		phase.raise_objection(this);
			fork
			incr_seq_0.start(env_h.master_top.master_agth[0].master_seqrh);
			incr_seq_1.start(env_h.master_top.master_agth[1].master_seqrh);
			join
			#1000;
		phase.drop_objection(this);
	endtask
endclass

class wrap_test extends base_test;
	`uvm_component_utils(wrap_test)
	
	wrap_sequence_mast_0 wrap_seq_0;
	wrap_sequence_mast_1 wrap_seq_1;

	function new(string name="wrap_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
//		super.run_phase(phase);
		wrap_seq_0=wrap_sequence_mast_0::type_id::create("wrap_seq_0");
		wrap_seq_1=wrap_sequence_mast_1::type_id::create("wrap_seq_1");
		
		phase.raise_objection(this);
			fork
			begin
			wrap_seq_0.start(env_h.master_top.master_agth[0].master_seqrh);
			wrap_seq_1.start(env_h.master_top.master_agth[1].master_seqrh);
			end
			join
			#1000;
		phase.drop_objection(this);
	endtask
endclass
