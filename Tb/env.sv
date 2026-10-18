class env extends uvm_env;
	`uvm_component_utils(env)
	env_config env_cfg;
	master_agent_top master_top;
	slave_agent_top slave_top;
	reset_agent_top reset_top;
	scoreboard sb;


	extern function new(string name="env", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass

	function env :: new(string name="env",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void env :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(env_config) :: get(this,"","env_config",env_cfg))
			`uvm_fatal("env","getting config failed")

		if(env_cfg.has_master_agent)
		begin
			master_top=master_agent_top::type_id::create("master_top",this);
		end

		if(env_cfg.has_slave_agent)
		begin
			slave_top=slave_agent_top::type_id::create("slave_top",this);
		end

		if(env_cfg.has_reset_agent)
		begin
			reset_top=reset_agent_top::type_id::create("reset_top",this);
		end

	
		if(env_cfg.has_scoreboard)
		begin
			sb=scoreboard::type_id::create("sb",this);
		end

	endfunction

	
	function void env :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		for(int i=0;i<(env_cfg.no_of_master_agents);i++)
		begin
			master_top.master_agth[i].master_monh.master_ap.connect(sb.master_fifoh[i].analysis_export);
		end
		for(int i=0;i<(env_cfg.no_of_slave_agents);i++)
		begin
			slave_top.slave_agth[i].slave_monh.slave_ap.connect(sb.slave_fifoh[i].analysis_export);
		end

		for(int i=0;i<(env_cfg.no_of_reset_agents);i++)
		begin

			reset_top.reset_agth[i].reset_monh.reset_ap.connect(sb.reset_fifoh[i].analysis_export);
		end

		
	endfunction
			

