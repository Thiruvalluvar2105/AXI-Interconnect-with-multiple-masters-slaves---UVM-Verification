class slave_driver extends uvm_driver #(master_xtn);
	`uvm_component_utils(slave_driver)
	slave_config slave_cfg;
	//virtual interface handle
	virtual axi_slave_interface.SLV_DRV_MP slave_vif;

	master_xtn q1[$],q2[$],q3[$];

	int mem[*];


	semaphore sem=new();
	semaphore sem1=new();
	semaphore sem2=new(1);
	semaphore sem3=new(1);
	semaphore sem4=new(1);
	semaphore sem5=new(1);
	semaphore sem6=new(1);
	semaphore sem7=new();

	
	extern function new(string name="slave_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut();
	extern task drive_write_address();
	extern task drive_write_data(master_xtn xtn1);
	extern task drive_write_response(master_xtn xtn1);
	extern task drive_read_address();
	extern task drive_read_data(master_xtn xtn4);
	
endclass

	function slave_driver :: new(string name="slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void slave_driver :: build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slave_config) :: get(this,"","slave_config",slave_cfg))
		begin
			`uvm_fatal("SLAVE_DRIVER","getting config failed")
		end	
	endfunction

	function void slave_driver :: connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		slave_vif=slave_cfg.slave_vif;
	endfunction

	task slave_driver :: run_phase(uvm_phase phase);
		forever
			begin
				//seq_item_port.get_next_item(req);
				send_to_dut();
			//	seq_item_port.item_done();
				$display("slave_driver finished driving");
			end
	endtask

	task slave_driver :: send_to_dut();
		//driving logic to receive the write/read address and control information
		//write data and to send the write response, read data and write/read response
		//`uvm_info("slave_driver",$sformatf("diving master xtn to interface=%s",xtn.sprint()),UVM_MEDIUM)
		
		fork
			begin
				sem3.get(1);
				$display("============== slave driver before drive write address=================");
				drive_write_address();
				$display("============= slave driver after wrote address=======================");
				sem.put(1);
				sem3.put(1);
			end

			begin
				sem.get(1);
				sem2.get(1); //check y ur getting with sem2
				drive_write_data(q1.pop_front());
				sem1.put(1);
				sem2.put(1);
				$display("write data task eneded and semaphore should be set");
			end
	
			begin
				sem1.get(1);
				sem4.get(1);
				drive_write_response(q3.pop_front());
				sem4.put(1);
			end

			begin
				sem5.get(1);
				drive_read_address();
				sem7.put(1);
				sem5.put(1);
			end

			begin
				sem7.get(1);
				sem6.get(1);
				drive_read_data(q2.pop_front());
				sem6.put(1);
			end
		join
	endtask

	task slave_driver :: drive_write_address();
		//logic to receive write address and control information

		master_xtn xtn1;
		xtn1=master_xtn::type_id::create("xtn1");
		
		slave_vif.slv_drv_cb.AWREADY<=1'b1;
		//@(slave_vif.slv_drv_cb);
		wait(slave_vif.slv_drv_cb.AWVALID);
		xtn1.AWID =slave_vif.slv_drv_cb.AWID;	
		xtn1.AWADDR =slave_vif.slv_drv_cb.AWADDR;
		xtn1.AWLEN =slave_vif.slv_drv_cb.AWLEN;
		xtn1.AWSIZE =slave_vif.slv_drv_cb.AWSIZE;
		xtn1.AWBURST =slave_vif.slv_drv_cb.AWBURST;
		xtn1.AWLOCK =slave_vif.slv_drv_cb.AWLOCK;
		xtn1.AWCACHE =slave_vif.slv_drv_cb.AWCACHE;
		xtn1.AWPROT =slave_vif.slv_drv_cb.AWPROT;
		xtn1.AWQOS =slave_vif.slv_drv_cb.AWQOS;
		xtn1.AWUSER =slave_vif.slv_drv_cb.AWUSER;
		xtn1.AWVALID =slave_vif.slv_drv_cb.AWVALID;
	
		q1.push_back(xtn1);
		q3.push_back(xtn1);
		
		slave_vif.slv_drv_cb.AWREADY<=1'b0;
		repeat($urandom_range(1,5))
			@(slave_vif.slv_drv_cb);
		$display("====== slave write address driver task ended====");
		`uvm_info("SLAVE_DRIVER_WRITE_ADDRESS",$sformatf("data from the drive write address \n %s",xtn1.sprint()),UVM_LOW)
	endtask

	task slave_driver :: drive_write_data(master_xtn xtn1);
		//logic to receive write data

		master_xtn xtn2;
		xtn2=master_xtn::type_id::create("xtn2");
		xtn2=xtn1;
		xtn2.write_addr_cal();
		xtn2.WDATA=new[xtn2.AWLEN+1];

		foreach(xtn2.WDATA[i])
		begin
			slave_vif.slv_drv_cb.WREADY<=1'b1;
			@(slave_vif.slv_drv_cb);
			wait(slave_vif.slv_drv_cb.WVALID);
			xtn2.WUSER=slave_vif.slv_drv_cb.WUSER;
			xtn2.WVALID=slave_vif.slv_drv_cb.WVALID;

			if(xtn2.WSTRB[i]==4'b1111)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA;
			end
		
			else if(xtn2.WSTRB[i]==4'b0011)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[15:0];
			end
			else if(xtn2.WSTRB[i]==4'b0001)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[7:0];
			end
			else if(xtn2.WSTRB[i]==4'b1110)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[31:8];
			end
			else if(xtn2.WSTRB[i]==4'b1100)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[31:16];
			end
			else if(xtn2.WSTRB[i]==4'b1000)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[31:24];
			end
			else if(xtn2.WSTRB[i]==4'b0100)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[23:16];
			end
			else if(xtn2.WSTRB[i]==4'b0010)
			begin
				mem[xtn2.w_addr[i]]=slave_vif.slv_drv_cb.WDATA[15:8];
			end
		
			slave_vif.slv_drv_cb.WREADY<=1'b0;
			repeat($urandom_range(1,5))
			@(slave_vif.slv_drv_cb);
		end
		$display("===== slave_drive write data task ended=====");
		`uvm_info("SLAVE DRIVE WRITE DATA TASK",$sformatf("data from slave drive write data \n %s",xtn2.sprint()),UVM_LOW)
	endtask

	task slave_driver :: drive_write_response(master_xtn xtn1);

		//after receiving all the data slave have to send the response
		//below is the driving logic to send the response

		master_xtn xtn3;
		xtn3=master_xtn::type_id::create("xtn3");
		xtn3=xtn1;
		
		//callback
		
		slave_vif.slv_drv_cb.BVALID<=1'b1;
		slave_vif.slv_drv_cb.BID<=xtn3.AWID;
		slave_vif.slv_drv_cb.BUSER<=xtn3.BUSER;
		slave_vif.slv_drv_cb.BRESP<=1'b0;

		@(slave_vif.slv_drv_cb);
		wait(slave_vif.slv_drv_cb.BREADY);
		slave_vif.slv_drv_cb.BVALID<=1'b0;
		repeat($urandom_range(1,5))
		@(slave_vif.slv_drv_cb)
		$display("===== slave drive write respons task ended======");
		`uvm_info("SLAVE_DRIVE WRITE RESPONSE",$sformatf("data from slave drive write response \n %s",xtn3.sprint()),UVM_LOW)
	endtask

	task slave_driver :: drive_read_address();
		master_xtn xtn4;
		xtn4=master_xtn::type_id::create("xtn4");
		
		slave_vif.slv_drv_cb.ARREADY<=1'b1;
		@(slave_vif.slv_drv_cb);
		wait(slave_vif.slv_drv_cb.ARVALID);

		xtn4.ARADDR=slave_vif.slv_drv_cb.ARADDR;	
		xtn4.ARLEN=slave_vif.slv_drv_cb.ARLEN;
		xtn4.ARID=slave_vif.slv_drv_cb.ARID;
		xtn4.ARSIZE=slave_vif.slv_drv_cb.ARSIZE;
		xtn4.ARBURST=slave_vif.slv_drv_cb.ARBURST;
		xtn4.ARLOCK=slave_vif.slv_drv_cb.ARLOCK;
		xtn4.ARCACHE=slave_vif.slv_drv_cb.ARCACHE;
		xtn4.ARPROT=slave_vif.slv_drv_cb.ARPROT;
		xtn4.ARQOS=slave_vif.slv_drv_cb.ARQOS;
		xtn4.ARUSER=slave_vif.slv_drv_cb.ARUSER;	
		xtn4.ARVALID=slave_vif.slv_drv_cb.ARVALID;
	
		q2.push_back(xtn4);
		slave_vif.slv_drv_cb.ARREADY<=1'b0;
		repeat($urandom_range(1,5))
		@(slave_vif.slv_drv_cb);

		$display("===== slave drive read address task ended=====");
		`uvm_info("SLAVE DRIVE READ ADDRESS TASK",$sformatf("data from slave drive read address task \n %s",xtn4.sprint()),UVM_LOW)
	endtask

	task slave_driver :: drive_read_data(master_xtn xtn4);
		//logic to send read address and read response

		master_xtn xtn5;
		xtn5=master_xtn::type_id::create("xtn5");
		xtn5=xtn4;	
		xtn5.read_addr_cal();

		xtn5.RDATA=new[xtn5.ARLEN+1];

		//call back

		for(int i=0;i<(xtn5.ARLEN+1);i++)
		begin
			//xtn5.RDATA[i]=$urandom;
			slave_vif.slv_drv_cb.RVALID<=1'b1;
			slave_vif.slv_drv_cb.RID<=xtn5.ARID;
			slave_vif.slv_drv_cb.RUSER<=xtn5.RUSER;
			slave_vif.slv_drv_cb.RDATA<=$urandom;
			slave_vif.slv_drv_cb.RRESP<=1'b0;
			
			if(i==(xtn5.ARLEN))
			begin
				slave_vif.slv_drv_cb.RLAST<=1'b1;
			end
			else
			begin
			slave_vif.slv_drv_cb.RLAST<=1'b0;
			end
			@(slave_vif.slv_drv_cb);
			wait(slave_vif.slv_drv_cb.RREADY);
			/*do
				begin
					@(slave_vif.slv_drv_cb);
				end
			while(!slave_vif.slv_drv_cb.RREADY);
			*/
			slave_vif.slv_drv_cb.RVALID<=1'b0;
			slave_vif.slv_drv_cb.RLAST<=1'b0;
			repeat($urandom_range(1,5))
			@(slave_vif.slv_drv_cb);
			
			$display("===== slave drive READ data task ended=====");
			`uvm_info("SLAVE DRIVE READ DATA TASK",$sformatf("data from slave drive read data \n %s",xtn5.sprint()),UVM_LOW)
		end

	endtask
		
		//report phase willbe tehre for displaying count
