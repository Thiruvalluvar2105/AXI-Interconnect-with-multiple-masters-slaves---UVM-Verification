class reset_sequence extends uvm_sequence #(reset_xtn);
	`uvm_object_utils(reset_sequence)

	function new(string name="reset_sequence");
		super.new(name);
	endfunction

endclass

