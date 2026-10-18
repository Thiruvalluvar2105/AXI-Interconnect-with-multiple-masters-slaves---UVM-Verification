class reset_sequencer extends uvm_sequencer #(reset_xtn);
	`uvm_component_utils(reset_sequencer)

	
	extern function new(string name="reset_sequencer", uvm_component parent);
endclass

	function reset_sequencer :: new(string name="reset_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction
