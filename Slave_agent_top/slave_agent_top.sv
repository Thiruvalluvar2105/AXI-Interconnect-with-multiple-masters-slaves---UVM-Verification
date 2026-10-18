class slave_agent_top extends uvm_env;
	`uvm_component_utils(slave_agent_top)
	env_config env_cfg;
	slave_agent slave_agth[];


	extern function new(string name="slave_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);

endclass

	function slave_agent_top :: new(string name="slave_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void slave_agent_top :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(env_config) :: get(this,"","env_config",env_cfg))
			`uvm_fatal("slave_agent_top","getting config failed")

		slave_agth=new[env_cfg.no_of_slave_agents];

		foreach(slave_agth[i])
		begin
			slave_agth[i]=slave_agent::type_id::create($sformatf("slave_agth[%0d]",i),this);

			uvm_config_db#(slave_config)::set(this,$sformatf("slave_agth[%0d]*",i),"slave_config",env_cfg.slave_cfg[i]);
		end


	endfunction




