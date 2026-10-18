class reset_xtn extends uvm_sequence_item;
	`uvm_object_utils(reset_xtn)

	function new(string name="reset_xtn");
		super.new(name);
	endfunction

	bit reset;

	function void do_print (uvm_printer printer);
		printer.print_field("reset",this.reset,1,UVM_BIN);
	endfunction

endclass

