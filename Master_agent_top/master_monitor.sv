class master_monitor extends uvm_monitor;
	`uvm_component_utils(master_monitor)
	master_config master_cfg;

	uvm_analysis_port #(master_xtn) master_ap;

	//virtual interface handle

	virtual axi_master_interface.MAST_MON_MP master_vif;
		
	extern function new(string name="master_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task handle_write_transaction(master_xtn xtn);
	extern task handle_read_transaction(master_xtn xtn);
endclass

	function master_monitor :: new(string name="master_monitor",uvm_component parent);
		super.new(name,parent);
		master_ap=new("master_ap",this);
	endfunction

	function void master_monitor :: build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(master_config):: get(this,"","master_config",master_cfg))
			`uvm_fatal("master_monitor","getting config failed")
	endfunction

	function void master_monitor :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		master_vif=master_cfg.master_vif;
	endfunction

	task master_monitor:: run_phase(uvm_phase phase);
		`uvm_info(get_full_name(),"master_monitor run_phase started",UVM_LOW)
		fork
			forever
				begin
					//`uvm_info(get_full_name(),"forever loop has started",UVM_LOW)	
					master_xtn write_xtn;
					@(master_vif.mast_mon_cb);
					wait((master_vif.mast_mon_cb.AWVALID) && (master_vif.mast_mon_cb.AWREADY));
					$display("=================== MASTER MONITOR awvalid and AWREADY  wait is done====================");
					
					write_xtn=master_xtn::type_id::create("write_xtn");
					write_xtn.AWID = master_vif.mast_mon_cb.AWID;	 
					write_xtn.AWADDR = master_vif.mast_mon_cb.AWADDR;
					write_xtn.AWLEN = master_vif.mast_mon_cb.AWLEN;
					write_xtn.AWSIZE = master_vif.mast_mon_cb.AWSIZE;
					write_xtn.AWBURST = master_vif.mast_mon_cb.AWBURST;
					write_xtn.AWUSER = master_vif.mast_mon_cb.AWUSER;
					write_xtn.AWLOCK = master_vif.mast_mon_cb.AWLOCK;
					write_xtn.AWPROT = master_vif.mast_mon_cb.AWPROT;
					write_xtn.AWQOS = master_vif.mast_mon_cb.AWQOS;
					write_xtn.AWCACHE = master_vif.mast_mon_cb.AWCACHE;
					write_xtn.AWVALID = master_vif.mast_mon_cb.AWVALID;
					write_xtn.AWREADY = master_vif.mast_mon_cb.AWREADY;

					write_xtn.WDATA = new[write_xtn.AWLEN+1];
					write_xtn.WSTRB = new[write_xtn.AWLEN+1];
					//`uvm_info(get_full_name(),"insdie forever loop",UVM_LOW)
					
					//collect write data
					$display("================MASTER MONITOR entering into forecah loop of WDATA================");
					foreach(write_xtn.WDATA[i])
					begin
						wait((master_vif.mast_mon_cb.WVALID) && (master_vif.mast_mon_cb.WREADY));
					$display("=================== MASTER MONITOR wvalid and WREADY  wait is done====================");
						
						write_xtn.WDATA[i] = master_vif.mast_mon_cb.WDATA;
						write_xtn.WSTRB[i] = master_vif.mast_mon_cb.WSTRB;
						if(i==(write_xtn.WDATA.size-1))
						begin
							write_xtn.WLAST = master_vif.mast_mon_cb.WLAST;
						end
						write_xtn.WUSER = master_vif.mast_mon_cb.WUSER;		
						write_xtn.WVALID = master_vif.mast_mon_cb.WVALID;	
						write_xtn.WREADY = master_vif.mast_mon_cb.WREADY;

					//	`uvm_info(get_full_name(),"insdie foreach of WDATA loop",UVM_LOW)
							
					end

					fork
						$display("====================== master monitor after sampling wdata entering into fork join_none=============");
						handle_write_transaction(write_xtn);
					join_none
				end

			forever
				begin
					master_xtn read_xtn;
					@(master_vif.mast_mon_cb);

					wait((master_vif.mast_mon_cb.ARVALID) && (master_vif.mast_mon_cb.ARREADY));
					$display("===================read_xtn wait is done====================");
					read_xtn=master_xtn::type_id::create("read_xtn");
					read_xtn.ARID = master_vif.mast_mon_cb.ARID;
					read_xtn.ARADDR = master_vif.mast_mon_cb.ARADDR;
					read_xtn.ARLEN = master_vif.mast_mon_cb.ARLEN;
					read_xtn.ARSIZE = master_vif.mast_mon_cb.ARSIZE;
					read_xtn.ARBURST = master_vif.mast_mon_cb.ARBURST;
					read_xtn.ARLOCK = master_vif.mast_mon_cb.ARLOCK;
					read_xtn.ARCACHE = master_vif.mast_mon_cb.ARCACHE;
					read_xtn.ARUSER = master_vif.mast_mon_cb.ARUSER;
					read_xtn.ARQOS = master_vif.mast_mon_cb.ARQOS;
					read_xtn.ARPROT = master_vif.mast_mon_cb.ARPROT;
					read_xtn.ARVALID = master_vif.mast_mon_cb.ARVALID;
					read_xtn.ARREADY = master_vif.mast_mon_cb.ARREADY;
					
					fork
						$display("====================== master monitor after sampling rdata entering into fork join_none=============");

						handle_read_transaction(read_xtn);
					join_none
				end
		join
	endtask	

	task master_monitor :: handle_write_transaction(master_xtn xtn);
		`uvm_info(get_full_name(),"handle write transaction task started",UVM_LOW)
		
		@(master_vif.mast_mon_cb);
		wait((master_vif.mast_mon_cb.BVALID) && (master_vif.mast_mon_cb.BREADY));
		$display("=================== MASTER MONITOR Bvalid and BREADY  wait is done====================");

		xtn.BID = master_vif.mast_mon_cb.BID;		
		xtn.BRESP = master_vif.mast_mon_cb.BRESP;		
		xtn.BUSER = master_vif.mast_mon_cb.BUSER;		
		xtn.BVALID = master_vif.mast_mon_cb.BVALID;		
		xtn.BREADY = master_vif.mast_mon_cb.BREADY;
//		`uvm_info("MASTER MONITOR",$sformatf("displaying write_transaction from master monitor \n %s",xtn.sprint()),UVM_LOW)
		
		master_ap.write(xtn);
		`uvm_info("MASTER MONITOR",$sformatf("displaying write_transaction from master monitor \n %s",xtn.sprint()),UVM_LOW)
		

		//some increments
	endtask

	task master_monitor ::handle_read_transaction(master_xtn xtn);
		//`uvm_info(get_full_name(),"handleread transaction task started",UVM_LOW)
		
		xtn.RDATA = new[xtn.ARLEN+1];
		xtn.RRESP = new[xtn.ARLEN+1];
		
		foreach(xtn.RDATA[i])
		begin
			@(master_vif.mast_mon_cb);
			wait((master_vif.mast_mon_cb.RVALID) && (master_vif.mast_mon_cb.RREADY));
			xtn.RID = master_vif.mast_mon_cb.RID;
			xtn.RDATA[i] = master_vif.mast_mon_cb.RDATA;
			xtn.RRESP[i] = master_vif.mast_mon_cb.RRESP;
			if(i==(xtn.RDATA.size-1))
			begin
				xtn.RLAST = master_vif.mast_mon_cb.RLAST;
			end
			xtn.RVALID = master_vif.mast_mon_cb.RVALID;
			xtn.RREADY = master_vif.mast_mon_cb.RREADY;
		end

		master_ap.write(xtn);
		`uvm_info("MASTER MONITOR",$sformatf("displaying read_transaction from master monitor \n %s",xtn.sprint()),UVM_LOW)
		
			//some increments
	endtask
