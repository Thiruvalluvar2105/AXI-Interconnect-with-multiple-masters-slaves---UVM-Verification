class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)
	slave_config slave_cfg;

	uvm_analysis_port #(master_xtn) slave_ap;

	//virtual interface handle

	virtual axi_slave_interface.SLV_MON_MP slave_vif;
		
	extern function new(string name="slave_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task handle_write_transaction(master_xtn xtn);
	extern task handle_read_transaction(master_xtn xtn);
endclass

	function slave_monitor :: new(string name="slave_monitor",uvm_component parent);
		super.new(name,parent);
		slave_ap=new("slave_ap",this);
	endfunction

	function void slave_monitor :: build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slave_config):: get(this,"","slave_config",slave_cfg))
			`uvm_fatal("slave_monitor","getting config failed")
	endfunction

	function void slave_monitor :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		slave_vif=slave_cfg.slave_vif;
	endfunction

	task slave_monitor:: run_phase(uvm_phase phase);
		`uvm_info(get_full_name(),"slave_monitor run_phase started",UVM_LOW)
		fork
			forever
				begin
					//`uvm_info(get_full_name(),"forever loop has started",UVM_LOW)	
					master_xtn write_xtn;
					@(slave_vif.slv_mon_cb);
					wait((slave_vif.slv_mon_cb.AWVALID) && (slave_vif.slv_mon_cb.AWREADY));
					$display("=================== slvER MONITOR awvalid and AWREADY  wait is done====================");
					
					write_xtn=master_xtn::type_id::create("write_xtn");
					write_xtn.AWID = slave_vif.slv_mon_cb.AWID;	 
					write_xtn.AWADDR = slave_vif.slv_mon_cb.AWADDR;
					write_xtn.AWLEN = slave_vif.slv_mon_cb.AWLEN;
					write_xtn.AWSIZE = slave_vif.slv_mon_cb.AWSIZE;
					write_xtn.AWBURST = slave_vif.slv_mon_cb.AWBURST;
					write_xtn.AWUSER = slave_vif.slv_mon_cb.AWUSER;
					write_xtn.AWLOCK = slave_vif.slv_mon_cb.AWLOCK;
					write_xtn.AWPROT = slave_vif.slv_mon_cb.AWPROT;
					write_xtn.AWQOS = slave_vif.slv_mon_cb.AWQOS;
					write_xtn.AWCACHE = slave_vif.slv_mon_cb.AWCACHE;
					write_xtn.AWVALID = slave_vif.slv_mon_cb.AWVALID;
					write_xtn.AWREADY = slave_vif.slv_mon_cb.AWREADY;

					write_xtn.WDATA = new[write_xtn.AWLEN+1];
					write_xtn.WSTRB = new[write_xtn.AWLEN+1];
					//`uvm_info(get_full_name(),"insdie forever loop",UVM_LOW)
					
					//collect write data
					$display("================slvER MONITOR entering into forecah loop of WDATA================");
					foreach(write_xtn.WDATA[i])
					begin
						wait((slave_vif.slv_mon_cb.WVALID) && (slave_vif.slv_mon_cb.WREADY));
					$display("=================== slvER MONITOR wvalid and WREADY  wait is done====================");
						
						write_xtn.WDATA[i] = slave_vif.slv_mon_cb.WDATA;
						write_xtn.WSTRB[i] = slave_vif.slv_mon_cb.WSTRB;
						if(i==(write_xtn.WDATA.size-1))
						begin
							write_xtn.WLAST = slave_vif.slv_mon_cb.WLAST;
						end
						write_xtn.WUSER = slave_vif.slv_mon_cb.WUSER;		
						write_xtn.WVALID = slave_vif.slv_mon_cb.WVALID;	
						write_xtn.WREADY = slave_vif.slv_mon_cb.WREADY;

					//	`uvm_info(get_full_name(),"insdie foreach of WDATA loop",UVM_LOW)
							
					end

					fork
						$display("====================== slave monitor after sampling wdata entering into fork join_none=============");
						handle_write_transaction(write_xtn);
					join_none
				end

			forever
				begin
					master_xtn read_xtn;
					@(slave_vif.slv_mon_cb);

					wait((slave_vif.slv_mon_cb.ARVALID) && (slave_vif.slv_mon_cb.ARREADY));
					$display("===================read_xtn wait is done====================");
					read_xtn=master_xtn::type_id::create("read_xtn");
					read_xtn.ARID = slave_vif.slv_mon_cb.ARID;
					read_xtn.ARADDR = slave_vif.slv_mon_cb.ARADDR;
					read_xtn.ARLEN = slave_vif.slv_mon_cb.ARLEN;
					read_xtn.ARSIZE = slave_vif.slv_mon_cb.ARSIZE;
					read_xtn.ARBURST = slave_vif.slv_mon_cb.ARBURST;
					read_xtn.ARLOCK = slave_vif.slv_mon_cb.ARLOCK;
					read_xtn.ARCACHE = slave_vif.slv_mon_cb.ARCACHE;
					read_xtn.ARUSER = slave_vif.slv_mon_cb.ARUSER;
					read_xtn.ARQOS = slave_vif.slv_mon_cb.ARQOS;
					read_xtn.ARPROT = slave_vif.slv_mon_cb.ARPROT;
					read_xtn.ARVALID = slave_vif.slv_mon_cb.ARVALID;
					read_xtn.ARREADY = slave_vif.slv_mon_cb.ARREADY;
					
					fork
						$display("====================== slave monitor after sampling rdata entering into fork join_none=============");

						handle_read_transaction(read_xtn);
					join_none
				end
		join
	endtask	

	task slave_monitor :: handle_write_transaction(master_xtn xtn);
		`uvm_info(get_full_name(),"handle write transaction task started",UVM_LOW)
		
		@(slave_vif.slv_mon_cb);
		wait((slave_vif.slv_mon_cb.BVALID) && (slave_vif.slv_mon_cb.BREADY));
		$display("=================== SLAVER MONITOR Bvalid and BREADY  wait is done====================");

		xtn.BID = slave_vif.slv_mon_cb.BID;		
		xtn.BRESP = slave_vif.slv_mon_cb.BRESP;		
		xtn.BUSER = slave_vif.slv_mon_cb.BUSER;		
		xtn.BVALID = slave_vif.slv_mon_cb.BVALID;		
		xtn.BREADY = slave_vif.slv_mon_cb.BREADY;
//		`uvm_info("slvER MONITOR",$sformatf("displaying write_transaction from slave monitor \n %s",xtn.sprint()),UVM_LOW)
		
		slave_ap.write(xtn);
		`uvm_info("SLAVER MONITOR",$sformatf("displaying write_transaction from slave monitor \n %s",xtn.sprint()),UVM_LOW)
		

		//some increments
	endtask

	task slave_monitor ::handle_read_transaction(master_xtn xtn);
		//`uvm_info(get_full_name(),"handleread transaction task started",UVM_LOW)
		
		xtn.RDATA = new[xtn.ARLEN+1];
		xtn.RRESP = new[xtn.ARLEN+1];
		
		foreach(xtn.RDATA[i])
		begin
			@(slave_vif.slv_mon_cb);
			wait((slave_vif.slv_mon_cb.RVALID) && (slave_vif.slv_mon_cb.RREADY));
			xtn.RID = slave_vif.slv_mon_cb.RID;
			xtn.RDATA[i] = slave_vif.slv_mon_cb.RDATA;
			xtn.RRESP[i] = slave_vif.slv_mon_cb.RRESP;
			if(i==(xtn.RDATA.size-1))
			begin
				xtn.RLAST = slave_vif.slv_mon_cb.RLAST;
			end
			xtn.RVALID = slave_vif.slv_mon_cb.RVALID;
			xtn.RREADY = slave_vif.slv_mon_cb.RREADY;
		end

		slave_ap.write(xtn);
		`uvm_info("SLAVER MONITOR",$sformatf("displaying read_transaction from slave monitor \n %s",xtn.sprint()),UVM_LOW)
		
			//some increments
	endtask

