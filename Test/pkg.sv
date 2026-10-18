package pkg;
	

	import uvm_pkg::*;
	`include "uvm_macros.svh"


	`include "master_config.sv"
	`include "slave_config.sv"
	`include "reset_config.sv"
	`include "env_config.sv"

	`include "master_xtn.sv"
	`include "master_sequence.sv"
	`include "master_driver.sv"
	`include "master_monitor.sv"
	`include "master_sequencer.sv"
	`include "master_agent.sv"
	`include "master_agent_top.sv"

	
	`include "slave_sequence.sv"
	`include "slave_driver.sv"
	`include "slave_monitor.sv"
	`include "slave_sequencer.sv"
	`include "slave_agent.sv"
	`include "slave_agent_top.sv"

	`include "reset_xtn.sv"
	`include "reset_sequence.sv"
	`include "reset_driver.sv"
	`include "reset_monitor.sv"
	`include "reset_sequencer.sv"
	`include "reset_agent.sv"
	`include "reset_agent_top.sv"


	`include "scoreboard.sv"
	`include "env.sv"
	
	`include "test.sv"
endpackage
