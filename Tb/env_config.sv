class env_config extends uvm_object;
	`uvm_object_utils(env_config)

	master_config master_cfg[];
	slave_config slave_cfg[];
	reset_config reset_cfg[];

	bit has_master_agent;
	bit has_slave_agent;
	bit has_scoreboard;
	bit has_reset_agent;

	int no_of_master_agents;
	int no_of_slave_agents;
	int no_of_reset_agents;	

	function new(string name="env_config");
		super.new(name);
	endfunction

endclass
