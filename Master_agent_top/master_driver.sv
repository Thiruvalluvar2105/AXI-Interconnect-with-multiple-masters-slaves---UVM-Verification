class master_driver extends uvm_driver #(master_xtn);
	`uvm_component_utils(master_driver)

	master_config master_cfg;

	//virtual interface handle
	virtual axi_master_interface.MAST_DRV_MP master_vif;
	
	master_xtn q1[$],q2[$],q3[$],q4[$],q5[$];
	int w_mem[*];

	semaphore sem=new();
	semaphore sem1=new();
	semaphore sem2=new(1); //write address
	semaphore sem3=new(1); //write_data
	semaphore sem4=new(1); // write_response
	semaphore sem5=new(1); 
	semaphore sem6=new(1);
	semaphore sem7=new();



	extern function new(string name="master_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(master_xtn xtn);
	extern task write_address(master_xtn xtn);
	extern task write_data(master_xtn xtn);
	extern task write_response(master_xtn xtn);
	extern task read_address(master_xtn xtn);
	extern task read_data(master_xtn xtn);
endclass

	function master_driver :: new(string name="master_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void master_driver :: build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(master_config) :: get(this,"","master_config",master_cfg))
			`uvm_fatal("master_driver","getting interface failed")

	endfunction

	function void master_driver :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		master_vif=master_cfg.master_vif;
	endfunction

	task master_driver::run_phase(uvm_phase phase);
		super.run_phase(phase);	
		forever

			begin
				seq_item_port.get_next_item(req);
				send_to_dut(req);
				seq_item_port.item_done();
			end
	endtask

	task master_driver :: send_to_dut(master_xtn xtn);
		`uvm_info("master_driver",$sformatf("driving master xtn to interface=%s",xtn.sprint()),UVM_MEDIUM)

			q1.push_back(xtn);
			q2.push_back(xtn);
			q3.push_back(xtn);
			q4.push_back(xtn);
			q5.push_back(xtn);


		      fork
			begin
				sem3.get(1);
				$display("================MASTER DRIVER before write address task====================");
				write_address(q1.pop_front());
				$display("================MASTER DRIVER 1st thread giving access to write data====================");
				sem.put(1);
				$display("================MASTER DRIVER 1st thread giving access to write data====================");
				sem3.put(1);
				$display("================MASTER DRIVER after write address task sem3.put====================");
				
			end

			begin
				sem.get(1);
				$display("================= master drover sem.get before write data task==============");
				sem2.get(1);
				$display("================= master driver sem2.get=========================");
				write_data(q2.pop_front());
				$display("=================master driver write data task=================");
				sem1.put(1);
				sem2.put(1);
			end

			begin
				sem1.get(1);
				sem4.get(1);
				write_response(q3.pop_front());
				sem4.put(1);
			end

			begin
				sem5.get(1);
				read_address(q4.pop_front());
				sem7.put(1);
				sem5.put(1);
			end

			begin
				sem7.get(1);
				$display("==================master driver before calling read  data task ===============");
				sem6.get(1);
				read_data(q5.pop_front());
				$display("=================master driver after calling read data task======================");
				sem6.put(1);
			end

		   join
							
	endtask

	task master_driver :: write_address(master_xtn xtn);

		master_vif.mast_drv_cb.AWVALID<=1'b1;
		master_vif.mast_drv_cb.AWID <= xtn.AWID;
		master_vif.mast_drv_cb.AWADDR <= xtn.AWADDR;
		master_vif.mast_drv_cb.AWLEN <= xtn.AWLEN;
		master_vif.mast_drv_cb.AWSIZE <= xtn.AWSIZE;
		master_vif.mast_drv_cb.AWBURST <= xtn.AWBURST;
		master_vif.mast_drv_cb.AWLOCK <= xtn.AWLOCK;
		master_vif.mast_drv_cb.AWCACHE <= xtn.AWCACHE;
		master_vif.mast_drv_cb.AWPROT <= xtn.AWPROT;
		master_vif.mast_drv_cb.AWQOS <= xtn.AWQOS;
		master_vif.mast_drv_cb.AWUSER <= xtn.AWUSER;

		//AWVALID should be high till slave asserts AWREADY

		//@(master_vif.mast_drv_cb);
		wait(master_vif.mast_drv_cb.AWREADY)
		master_vif.mast_drv_cb.AWVALID<=1'b0;

		repeat($urandom_range(1,5))
		@(master_vif.mast_drv_cb);
		
		$display("======master address driver task end=====");
		`uvm_info("MASTER DRIVER DRVING WRITE ADDRESS",$sformatf("data from master driver=%s",xtn.sprint()),UVM_LOW)
	endtask

	task master_driver :: write_data(master_xtn xtn);
	
		//in data phase the write data will be sent when slave is ready to receive the data(WREADY will be bhigh)
		//the no_of data to be transferred will be equal to AWLEN+1
		// when we are sending the last data the WLAST signal will be asserted

		$display("======= master data driver task before AWLEN=%0d",xtn.AWLEN);

		for(int i=0;i<xtn.AWLEN+1;i++)
		begin
			master_vif.mast_drv_cb.WVALID<=1'b1;
			master_vif.mast_drv_cb.WUSER<=xtn.WUSER;
			master_vif.mast_drv_cb.WDATA<=xtn.WDATA[i];
			master_vif.mast_drv_cb.WSTRB<=xtn.WSTRB[i];

			$display("====== master data driver task outside AWLEN=%0d",xtn.AWLEN);

			if(i==(xtn.AWLEN))
			begin
				master_vif.mast_drv_cb.WLAST<=1'b1;
				$display("====== master data driver task AWLEN=%0d",xtn.AWLEN);
			end
			else
			begin
				master_vif.mast_drv_cb.WLAST<=1'b0;
			end
			
			@(master_vif.mast_drv_cb);
			wait(master_vif.mast_drv_cb.WREADY)
			
			master_vif.mast_drv_cb.WVALID<=1'b0;
			master_vif.mast_drv_cb.WLAST<=1'b0;
		
			repeat($urandom_range(1,5))
			@(master_vif.mast_drv_cb);
		end
	
		`uvm_info("MATSER DRVING WRITE DATA",$sformatf("displaying write data from master driver \n %s",xtn.sprint()),UVM_LOW)
	endtask

	task master_driver :: write_response(master_xtn xtn);
		//after sending all the data master will be ready to receive the response by making the BREADY signal high

		master_vif.mast_drv_cb.BREADY<=1'b1;
	//	@(master_vif.mast_drv_cb);
		wait(master_vif.mast_drv_cb.BVALID)
		master_vif.mast_drv_cb.BREADY<=1'b0;
		repeat($urandom_range(1,5))
		@(master_vif.mast_drv_cb);
		$display("====== master write response driver task end=====");
		`uvm_info("MASTER DRIVER WRITE RESPONSE",$sformatf("displaying data from master driver write response \n %s",xtn.sprint()),UVM_LOW)
	endtask

	task master_driver :: read_address(master_xtn xtn);
		//in read address phase the read address and control information will be sent at posedge of the clock
		
		master_vif.mast_drv_cb.ARVALID<=1'b1;
		master_vif.mast_drv_cb.ARID<=xtn.ARID;
		master_vif.mast_drv_cb.ARADDR<=xtn.ARADDR;
		master_vif.mast_drv_cb.ARLEN<=xtn.ARLEN;
		master_vif.mast_drv_cb.ARSIZE<=xtn.ARSIZE;
		master_vif.mast_drv_cb.ARBURST<=xtn.ARBURST;
		master_vif.mast_drv_cb.ARLOCK<=xtn.ARLOCK;
		master_vif.mast_drv_cb.ARCACHE<=xtn.ARCACHE;
		master_vif.mast_drv_cb.ARPROT<=xtn.ARPROT;
		master_vif.mast_drv_cb.ARQOS<=xtn.ARQOS;
		master_vif.mast_drv_cb.ARUSER<=xtn.ARUSER;

		//q5.push_back(xtn);
		
		//the ARVALID will be asserted till slave is ready(ARREADY=1)

		//@(master_vif.mast_drv_cb);
		wait(master_vif.mast_drv_cb.ARREADY)
		master_vif.mast_drv_cb.ARVALID<=1'b0;
		repeat($urandom_range(1,5))
		@(master_vif.mast_drv_cb);

		$display("==== master read address driver task end===");
		`uvm_info("master driver read address",$sformatf("displaying the master driver read address \n %s",xtn.sprint()),UVM_LOW)
	endtask

	task master_driver:: read_data(master_xtn xtn);
		//the read data will be collected at posedge of the clock
		// the no_of datas will be equal to AWLEN+1

		xtn.read_addr_cal();
		xtn.RDATA=new[xtn.ARLEN+1];
		for(int i=0; i<(xtn.ARLEN+1); i++)
		begin
			master_vif.mast_drv_cb.RREADY<=1'b1;
		//	@(master_vif.mast_drv_cb);
			wait(master_vif.mast_drv_cb.RVALID)
			/*do
				begin
					@(master_vif.mast_drv_cb);
				end
			while(!master_vif.mast_drv_cb.RVALID);
			*/
			xtn.RDATA[i]=master_vif.mast_drv_cb.RDATA;

			master_vif.mast_drv_cb.RREADY<=1'b0;
			repeat($urandom_range(1,5))
			@(master_vif.mast_drv_cb);
		end
		$display("==== master read data driver task end====");
		`uvm_info("MASTER DRIVER READ DATA",$sformatf("displaying the master driver read data \n %s",xtn.sprint()),UVM_LOW)
	endtask

	/*function void master_driver :: report_phase(uvm_phase phase);
		`uvm_info("MASTER DRIVER REPORT PHASE",$sformatf("report: master driver has sent %0d trasactions ",master_cfg.mast_drv_xtn_sent_cnt),UVM_LOW)
	endfunction*/
