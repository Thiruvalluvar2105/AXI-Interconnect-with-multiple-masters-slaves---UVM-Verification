class reset_agent_top extends uvm_env;
	`uvm_component_utils(reset_agent_top)
	env_config env_cfg;
	reset_agent reset_agth[];


	extern function new(string name="reset_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);

endclass

	function reset_agent_top :: new(string name="reset_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void reset_agent_top :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(env_config) :: get(this,"","env_config",env_cfg))
			`uvm_fatal("reset_agent_top","getting config failed")

		reset_agth=new[env_cfg.no_of_reset_agents];

		foreach(reset_agth[i])
		begin
			reset_agth[i]=reset_agent::type_id::create($sformatf("reset_agth[%0d]",i),this);

			uvm_config_db#(reset_config)::set(this,$sformatf("reset_agth[%0d]*",i),"reset_config",env_cfg.reset_cfg[i]);
		end


	endfunction




