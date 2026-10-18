class master_xtn extends uvm_sequence_item;
	`uvm_object_utils(master_xtn)


	rand bit resetn;
	//wite address channel signals

	rand bit[7:0] 	AWID;
	rand bit[31:0] 	AWADDR;
	rand bit 	AWVALID;
	rand bit	AWREADY;
	rand bit[7:0] 	AWLEN;
	rand bit[2:0] 	AWSIZE;
	rand bit[1:0] 	AWBURST;
	rand bit 	AWLOCK;
	rand bit[2:0] 	AWPROT;
	rand bit[3:0] 	AWCACHE;
	rand bit[3:0] 	AWQOS;
	rand bit 	AWUSER;
	

	//write data channel signals

	//rand bit[7:0] WID; // check this it should be there
	rand bit[31:0] 	WDATA[];
	rand bit[3:0] 	WSTRB[];	
	rand bit 	WVALID;
	rand bit 	WREADY;
	rand bit 	WLAST;
	rand bit 	WUSER;

	
	//write response channel signals

	rand bit[7:0] 	BID;
	rand bit[1:0] 	BRESP;
	rand bit 	BVALID;
	rand bit 	BREADY;
	rand bit 	BUSER;

	//read  address channel signals

	rand bit[7:0] 	ARID;
	rand bit[31:0] 	ARADDR;
	rand bit 	ARVALID;
	rand bit 	ARREADY;
	rand bit[7:0] 	ARLEN;
	rand bit[2:0] 	ARSIZE;
	rand bit[1:0] 	ARBURST;
	rand bit	ARUSER;
	rand bit 	ARLOCK;
	rand bit[2:0] 	ARPROT;
	rand bit[3:0] 	ARCACHE;
	rand bit[3:0] 	ARQOS;

	
	//read data channel signals

	rand bit[7:0] 	RID;
	rand bit[31:0] 	RDATA[];
	rand bit 	RVALID;
	rand bit 	RREADY;
	rand bit[1:0] 	RRESP[]; //the response size is Dynamic because for every transfer of read data so it should be the size of burst THAT IS NO OF TRANSFERS
	rand bit 	RLAST;
	rand bit 	RUSER;
	
	//local variables
	
	bit[31:0] 	w_addr[];
	bit[31:0] 	r_addr[];
	rand bit[1:0] 	read_slave;
	rand bit[1:0] 	write_slave;

	//constraints

	constraint vald_reset {resetn==1'b1;}
	
	constraint valid_AWVALID {AWVALID dist{1:=499,0:=1};}

	
	constraint valid_R_ID {ARID inside {[1:255]};
				RID == ARID;
					}
	constraint valid_write{AWID==BID;}
	
	constraint valid_AWUSER{ AWUSER == 0;
				WUSER == AWUSER;
				BUSER == AWUSER;}
	
	constraint valid_ARUSER { ARUSER == 0;
				  RUSER == ARUSER;
				}


	constraint valid_burst_awaddr {
					solve AWSIZE before AWBURST;
					if(AWBURST==2)
						if(AWSIZE==1)
							AWADDR%2==0;
						else if(AWSIZE==2)
							AWADDR%4==0;
				      }

	constraint valid_burst_araddr {
					solve ARSIZE before ARBURST;
						if(ARBURST==2)
							if(ARSIZE==1)
								ARADDR%2==0;
							else if(ARSIZE==2)
								ARADDR%4==0;
				     }

	constraint valid_AWADDR {
					solve write_slave before AWADDR;
					solve AWBURST before AWADDR;
					if(write_slave==0)
						AWADDR inside {[32'h4000_0000 : 32'h4000_0fff]};
					else if(write_slave==1)
						AWADDR inside {[32'h4000_1000 : 32'h4000_1fff]};
					else if(write_slave==2)
						AWADDR inside {[32'h4000_2000 : 32'h4000_2fff]};
				}

	constraint valid_ARADDR {
					solve read_slave before ARADDR;
					solve ARBURST before ARADDR;
					if(read_slave==0)
						ARADDR inside {[32'h4000_0000 : 32'h4000_0fff]};
					else if(read_slave==1)
						ARADDR inside {[32'h4000_1000 : 32'h4000_1fff]};
					else if(read_slave==2)
						ARADDR inside {[32'h4000_2000 : 32'h4000_2fff]};
				}

	constraint valid_AWBURST { AWBURST inside {0,1,2};}
	constraint valid_ARBURST { ARBURST inside {0,1,2};}
	

	constraint valid_AWSIZE { 8*(2**AWSIZE) <=32;}
	constraint valid_ARSIZE { 8*(2**ARSIZE) <=32;}

	constraint vaid_WDATA_SIZE {
					WDATA.size==AWLEN+1;
				   }

	constraint valid_RDATA_SIZE {
					RDATA.size==ARLEN+1;
				    }

	constraint valid_ARADDR_RRESP { RRESP.size== RDATA.size;}

	constraint valid_AWLEN {
					solve AWBURST before AWLEN;
					if(AWBURST==0)
						soft AWLEN inside {[0:2]};
					else if(AWBURST==1)
						soft AWLEN inside {[1:2]};
					else if(AWBURST==2)
						soft AWLEN inside {1,3};
			      }

	constraint valid_ARLEN {
					solve ARBURST before ARLEN;
					if(ARBURST==0)
						soft ARLEN inside {[0:255]};
					else if(ARBURST==1)
						soft ARLEN inside {[1:255]};
					else if(ARBURST==2)
						soft ARLEN inside {1,3,7,15,31,63,127,255};
			      }

	constraint valid_RRESP{
					foreach(RRESP[i])
						RRESP[i]==0;} //0 means OKAY
	
	constraint valid_BRESP{
					BRESP==0;
				}

		
	//constraint wdata{WDATA<4000;}
	//constraint rdata{RDATA<4000;}


	extern function new(string name="master_xtn");
	extern function void post_randomize();
	extern function void do_print(uvm_printer printer);
	extern function write_addr_cal();
	extern function strobe_cal();
	extern function read_addr_cal();
		
endclass

 
	function master_xtn::new(string name="master_xtn");
		super.new(name);
	endfunction

	function void master_xtn::do_print(uvm_printer printer);
		super.do_print(printer);
		
		printer.print_field("AWID",this.AWID,8,UVM_DEC);
		printer.print_field("AWADDR",this.AWADDR,32,UVM_DEC);
		printer.print_field("AWVALID",this.AWVALID,1,UVM_BIN);
		printer.print_field("AWREADY",this.AWREADY,1,UVM_BIN);
		printer.print_field("AWLEN",this.AWLEN,8,UVM_DEC);
		printer.print_field("AWSIZE",this.AWSIZE,3,UVM_DEC);
		printer.print_field("AWBURST",this.AWBURST,2,UVM_DEC);
		printer.print_field("AWLOCK",this.AWLOCK,1,UVM_BIN);
		printer.print_field("AWPROT",this.AWPROT,3,UVM_BIN);
		printer.print_field("AWCACHE",this.AWCACHE,4,UVM_BIN);
		printer.print_field("AWQOS",this.AWQOS,4,UVM_BIN);
		printer.print_field("AWUSER",this.AWUSER,1,UVM_BIN);

	
		printer.print_field("WVALID",this.WVALID,1,UVM_BIN);
		printer.print_field("WREADY",this.WREADY,1,UVM_BIN);
		printer.print_field("WLAST",this.WLAST,1,UVM_BIN);
		printer.print_field("WUSER",this.WUSER,1,UVM_BIN);
		//WDATA AND WSTRB are dynamic arrays print them as well strb 4 bit and data is 32bit

		foreach(WDATA[i])
		begin
			printer.print_field($sformatf("WDATA[%0h]",i),this.WDATA[i],32,UVM_HEX);
		end

		foreach(WSTRB[i])
		begin
			printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_DEC);
		end


		printer.print_field("BID",this.BID,8,UVM_DEC);		
		printer.print_field("BVALID",this.BVALID,1,UVM_BIN);
		printer.print_field("BREADY",this.BREADY,1,UVM_BIN);
		printer.print_field("BRESP",this.BRESP,2,UVM_DEC);
		printer.print_field("BUSER",this.BUSER,1,UVM_BIN);



		printer.print_field("ARID",this.ARID,8,UVM_DEC);
		printer.print_field("ARADDR",this.ARADDR,32,UVM_DEC);
		printer.print_field("ARVALID",this.ARVALID,1,UVM_BIN);
		printer.print_field("ARREADY",this.ARREADY,1,UVM_BIN);
		printer.print_field("ARLEN",this.ARLEN,8,UVM_DEC);
		printer.print_field("ARSIZE",this.ARSIZE,3,UVM_DEC);
		printer.print_field("ARBURST",this.ARBURST,2,UVM_DEC);
	
		printer.print_field("RID",this.RID,8,UVM_DEC);		
		printer.print_field("RVALID",this.RVALID,1,UVM_BIN);
		printer.print_field("RREADY",this.RREADY,1,UVM_BIN);
		printer.print_field("RLAST",this.RLAST,1,UVM_BIN);
		printer.print_field("RUSER",this.RUSER,1,UVM_BIN);
		//RDATA 32 bit  AND RRESP 2 BIT ARE DYAMIC ARRAYS
		foreach(RDATA[i])
		begin
			printer.print_field($sformatf("RDATA[%0h]",i),this.RDATA[i],32,UVM_HEX);
		end

		foreach(RRESP[i])
		begin
			printer.print_field($sformatf("RRESP[%0d]",i),this.RRESP[i],2,UVM_DEC);
		end
			


	endfunction

	function void master_xtn :: post_randomize();
		fork
			write_addr_cal();
			read_addr_cal();
		join_none
	endfunction

	function master_xtn :: write_addr_cal();
		bit k=0;
		
		int w_wrap_lower_boundary;
		int w_wrap_upper_boundary;
		int w_start_address=AWADDR;
		int w_no_of_bytes=2**(AWSIZE);
		int w_burst_length=AWLEN+1;
		int w_alligned_address=(int'(w_start_address/w_no_of_bytes))*w_no_of_bytes;
		w_addr=new[AWLEN+1];
		w_wrap_lower_boundary=(int'(AWADDR/(w_no_of_bytes*w_burst_length)))*(w_no_of_bytes*w_burst_length);
		w_wrap_upper_boundary=w_wrap_lower_boundary+(w_no_of_bytes*w_burst_length);

		w_addr[0]=AWADDR;

		for(int i=2;i<=(AWLEN+1);i++)
		begin
			if(AWBURST==0)
				w_addr[i-1]=AWADDR;
			else if(AWBURST==1)
				w_addr[i-1]=((int'(AWADDR/w_no_of_bytes))*(w_no_of_bytes))+((i-1)*(w_no_of_bytes));
			else if(AWBURST==2)
				if(k==0)
				begin
					w_addr[i-1]=((int'(AWADDR/w_no_of_bytes))*(w_no_of_bytes))+((i-1)*(w_no_of_bytes));
					if(w_addr[i-1]==(w_wrap_upper_boundary))
					begin
						w_addr[i-1]=w_wrap_lower_boundary;
						k++;
					end
				end
				else
					w_addr[i-1]=AWADDR+((i-1)*w_no_of_bytes)-(w_no_of_bytes*w_burst_length);
				strobe_cal();
		end
	endfunction

	function master_xtn::strobe_cal();
		int data_bus_bytes=4;
		int lower_byte_lane;
		int upper_byte_lane;
		int lower_byte_lane_0;
		int upper_byte_lane_0;
		int w_start_address=AWADDR;
		int w_no_of_bytes=2**(AWSIZE);
		int w_alligned_address=(int'(w_start_address/w_no_of_bytes))*(w_no_of_bytes);

		WSTRB=new[(AWLEN+1)];

		lower_byte_lane_0=w_start_address - (int'(w_start_address/data_bus_bytes))*data_bus_bytes;
		upper_byte_lane_0=(w_alligned_address+(w_no_of_bytes-1))-((int'(w_start_address/data_bus_bytes))*data_bus_bytes);


		for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
		begin
			WSTRB[0][j]=1;
		end

		for(int i=1;i<(WSTRB.size);i++)
		begin
			lower_byte_lane=w_addr[i]-(int'(w_addr[i]/data_bus_bytes))*data_bus_bytes;
			upper_byte_lane=lower_byte_lane+w_no_of_bytes-1;

			for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
			begin
				WSTRB[i][j]=1;
			end
		end
	endfunction

	function master_xtn::read_addr_cal();
		bit l=0;
		int r_wrap_lower_boundary;
		int r_wrap_upper_boundary;
		int r_start_address=ARADDR;
		int r_no_of_bytes=2**(ARSIZE);
		int r_burst_length=ARLEN+1;
		int r_alligned_address=(int'(r_start_address/r_no_of_bytes))*r_no_of_bytes;
		r_addr=new[ARLEN+1];
		r_wrap_lower_boundary=(int'(ARADDR/(r_no_of_bytes*r_burst_length)))*(r_no_of_bytes*r_burst_length);
		r_wrap_upper_boundary=r_wrap_lower_boundary+(r_no_of_bytes*r_burst_length);

		r_addr[0]=AWADDR;

		for(int i=2;i<=(ARLEN+1);i++)
		begin
			if(ARBURST==0)
				r_addr[i-1]=ARADDR;
			else if(ARBURST==1)
				r_addr[i-1]=((int'(ARADDR/r_no_of_bytes))*(r_no_of_bytes))+((i-1)*(r_no_of_bytes));
			else if(ARBURST==2)
				if(l==0)
				begin
					r_addr[i-1]=((int'(ARADDR/r_no_of_bytes))*(r_no_of_bytes))+((i-1)*(r_no_of_bytes));
					if(r_addr[i-1]==(r_wrap_upper_boundary))
					begin
						r_addr[i-1]=r_wrap_lower_boundary;
						l++;
					end
				end
			else
				r_addr[i-1]=ARADDR+((i-1)*r_no_of_bytes)-(r_no_of_bytes*r_burst_length);
				//strobe_cal();
		end
	endfunction
			
