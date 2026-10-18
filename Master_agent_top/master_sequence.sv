class master_sequence extends uvm_sequence #(master_xtn);
	`uvm_object_utils(master_sequence)

	function new(string name="master_sequence");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize () with {write_slave==0;read_slave==0; AWBURST==2;ARBURST==2;ARLEN==0;AWLEN==0;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence=%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask

endclass

class fixed_sequence_mast_0 extends master_sequence;
	`uvm_object_utils(fixed_sequence_mast_0)

	function new(string name="fixed_sequence_mast_0");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==0;read_slave==0;AWBURST==0;ARBURST==0;AWLEN==1;ARLEN==1;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=0 and r_slave=0 =%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask

endclass


class fixed_sequence_mast_1 extends master_sequence;
	`uvm_object_utils(fixed_sequence_mast_1)

	function new(string name="fixed_sequence_mast_1");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==1;read_slave==2;AWBURST==0;ARBURST==0;AWLEN==2;ARLEN==2;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=1 and r_slave=2 =%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask
endclass

class increment_sequence_mast_0 extends master_sequence;
	`uvm_object_utils(increment_sequence_mast_0)

	function new(string name="increment_sequence_mast_0");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==0;read_slave==2;AWBURST==1;ARBURST==1;AWLEN==3;ARLEN==3;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=0 and r_slave=2 =%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask
endclass

class increment_sequence_mast_1 extends master_sequence;
	`uvm_object_utils(increment_sequence_mast_1)

	function new(string name="increment_sequence_mast_1");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==2;read_slave==1;AWBURST==1;ARBURST==1;AWLEN==4;ARLEN==4;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=2 and r_slave=1 =%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask
endclass

class wrap_sequence_mast_0 extends master_sequence;
	`uvm_object_utils(wrap_sequence_mast_0)

	function new(string name="wrap_sequence_mast_0");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==2;read_slave==1;AWBURST==2;ARBURST==2;AWLEN==5;ARLEN==5;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=2 and r_slave=1 =%s",req.sprint()),UVM_MEDIUM);		
		finish_item(req);
	endtask
endclass


class wrap_sequence_mast_1 extends master_sequence;
	`uvm_object_utils(wrap_sequence_mast_1)

	function new(string name="wrap_sequence_mast_1");
		super.new(name);
	endfunction

	task body;
		req=master_xtn::type_id::create("req");
		//begin
		start_item(req);
		assert(req.randomize() with {write_slave==0;read_slave==2;AWBURST==2;ARBURST==2;AWLEN==6;ARLEN==6;});
		`uvm_info("master_sequence",$sformatf("generating sequence_item from sequence with w_slave=0 and r_slave=1 =%s",req.sprint()),UVM_MEDIUM);	
		finish_item(req);
	endtask
endclass
