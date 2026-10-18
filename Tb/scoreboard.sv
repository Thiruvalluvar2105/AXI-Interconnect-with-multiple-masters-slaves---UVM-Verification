class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	
	uvm_tlm_analysis_fifo#(master_xtn) master_fifoh[];
	uvm_tlm_analysis_fifo#(master_xtn) slave_fifoh[];
	uvm_tlm_analysis_fifo#(reset_xtn) reset_fifoh[];
	env_config env_cfg;
	
     // Associative arrays to store pending master transactions, indexed by ID.
     // We use a queue for each ID to handle multiple transactions with the same ID
     // (after the first one has completed).
     master_xtn m_write_pending[int][$]; // Key: AWID, Value: Queue of write transactions
     master_xtn m_read_pending[int][$];  // Key: ARID, Value: Queue of read transactions

	
     // Declare the Handles for Master and Slave Coverage Data
     master_xtn master_cov_data0;
     master_xtn slave_cov_data0; 
     master_xtn master_cov_data1;
     master_xtn slave_cov_data1; 
     master_xtn slave_cov_data2;
     reset_xtn rst_cov_data;

     int data_verified_count;
     bit pass=1;

     //Covergroup for Master 0
     covergroup master_covgrp0;
	option.per_instance = 0;
	
	RESET: coverpoint rst_cov_data.reset {bins rst ={0,1};}

	AW_ID :   coverpoint master_cov_data0.AWID {bins first_id={[1:51]};
						  bins second_id={[52:103]};
						  bins third_id = {[104:154]};
						  bins fourth_id = {[155:205]};
						  bins fifth_id ={[206:255]}; }

	AW_ADDR: coverpoint master_cov_data0.AWADDR{ bins first_slave = {[32'h4000_0000:32'h4000_0fff]};
						   bins second_slave ={[32'h4000_1000: 32'h4000_1fff]};
						   bins third_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AW_LENGTH: coverpoint master_cov_data0.AWLEN {bins fixed_type_awlen1={[1:255]} iff(master_cov_data0.AWBURST==2'b00);
						   /* bins fixed_type_awlen2={[52:103]} iff(master_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen3 = {[104:154]}iff(master_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen4= {[155:205]}iff(master_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen5 ={[206:255]}iff(master_cov_data0.AWBURST==2'b00);
						*/
						    bins incrm_type_awlen1={[1:255]}iff(master_cov_data0.AWBURST==2'b01);
						  /*  bins incrm_type_awlen2={[52:103]}iff(master_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen3 = {[104:154]}iff(master_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen4= {[155:205]}iff(master_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen5 ={[206:255]}iff(master_cov_data0.AWBURST==2'b01);
						*/
						    bins wrap_type_awlen1={[1:255]}iff(master_cov_data0.AWBURST==2'b10);}

						   /* bins wrap_type_awlen2 = {7,15}iff(master_cov_data0.AWBURST==2'b10);
						    bins wrap_type_awlen3= {31,63}iff(master_cov_data0.AWBURST==2'b10);
						    bins wrap_type_awlen4 ={127,255}iff(master_cov_data0.AWBURST==2'b10);}
						*/

	AW_BURST_SIZE: coverpoint master_cov_data0.AWSIZE {bins W_B_SIZE[] ={0,1,2};}

	AW_BURST_TYPE: coverpoint master_cov_data0.AWBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}
	AW_VALID: coverpoint master_cov_data0.AWVALID{ bins AWVALID ={0,1};}

	AW_READY:coverpoint master_cov_data0.AWREADY{bins AWREADY={0,1};}

	W_LAST:coverpoint master_cov_data0.WLAST{bins WLAST={0,1};}

	W_VALID: coverpoint master_cov_data0.WVALID{ bins WVALID ={0,1};}

	W_READY:coverpoint master_cov_data0.WREADY{bins WREADY={0,1};}

	B_ID :   coverpoint master_cov_data0.BID {bins first_id={[1:51]};
						bins second_id={[52:103]};
						bins third_id = {[104:154]};
						bins fourth_id = {[155:205]};
						bins fifth_id ={[206:255]}; }


	WRITE_RESP : coverpoint master_cov_data0.BRESP { bins W_RESP ={0,1,2,3}; }

	B_VALID: coverpoint master_cov_data0.BVALID{ bins BVALID ={0,1};}

	B_READY:coverpoint master_cov_data0.BREADY{bins BREADY ={0,1};}


	AR_ID: coverpoint master_cov_data0.ARID {bins first_id={[0:255]};}

	AR_ADDR: coverpoint master_cov_data0.ARADDR{ bins first_slave = {[32'h4000_0000:32'h4000_0fff]};
						   bins second_slave ={[32'h4000_1000: 32'h4000_1fff]};
						   bins third_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AR_LENGTH: coverpoint master_cov_data0.ARLEN {bins fixed_type_arlen1={[1:255]} iff(master_cov_data0.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:255]}iff(master_cov_data0.ARBURST==2'b01);
							
						    bins wrap_type_arlen4 ={[1:255]}iff(master_cov_data0.ARBURST==2'b10);}
							
						   /* bins fixed_type_arlen2={[52:103]} iff(master_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen3 = {[104:154]}iff(master_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen4= {[155:205]}iff(master_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen5 ={[206:255]}iff(master_cov_data0.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:51]}iff(master_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen2={[52:103]}iff(master_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen3 = {[104:154]}iff(master_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen4= {[155:205]}iff(master_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen5 ={[206:255]}iff(master_cov_data0.ARBURST==2'b01);
						    bins wrap_type_arlen1={1,3}iff(master_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen2 = {7,15}iff(master_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen3= {31,63}iff(master_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen4 ={127,255}iff(master_cov_data0.ARBURST==2'b10);}
						*/
	R_TRANSFER_SIZE: coverpoint master_cov_data0.ARSIZE { bins fixed_byte_transfer={0} iff(master_cov_data0.ARBURST==2'b00);
							  bins fixed_half_word_transfer={1} iff(master_cov_data0.ARBURST==2'b00);
							  bins fixed_word_transfer ={2} iff(master_cov_data0.ARBURST==2'b00);
 							  bins incrm_byte_transfer={0} iff(master_cov_data0.ARBURST==2'b01);
							  bins incrm_half_word_transfer={1} iff(master_cov_data0.ARBURST==2'b01);
							  bins incrm_word_transfer ={2} iff(master_cov_data0.ARBURST==2'b01);
 							  bins wrap_byte_transfer={0} iff(master_cov_data0.ARBURST==2'b10);
							  bins wrap_half_word_transfer={1} iff(master_cov_data0.ARBURST==2'b10);
							  bins wrap_word_transfer ={2} iff(master_cov_data0.ARBURST==2'b10);}

	AR_BURST_SIZE: coverpoint master_cov_data0.ARSIZE{bins R_B_SIZE ={0, 1, 2};}

	AR_BURST_TYPE: coverpoint master_cov_data0.ARBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	ARVALID: coverpoint master_cov_data0.ARVALID{bins ARVALID ={0,1};}

	ARREADY: coverpoint master_cov_data0.ARREADY{bins ARREADY={0,1};}

	R_ID: coverpoint master_cov_data0.RID {bins first_id={[0:255]};}

	R_LAST: coverpoint master_cov_data0.RLAST{bins RLAST ={0,1};}

	R_READY:coverpoint master_cov_data0.RREADY{bins RREADY ={0,1};}

	R_VALID: coverpoint master_cov_data0.RVALID{bins RVALID={0,1};}

        // Cross Bins
	ARVALID_ARREADY: cross ARVALID, ARREADY;
	R_VALID_R_READY: cross R_READY, R_VALID;
	R_VALID_R_READY_RLAST: cross R_READY, R_VALID, R_LAST;
	R_LEN_X_R_BURST_SIZE: cross AR_LENGTH, AR_BURST_SIZE;


        // Cross Bins
	AW_VALID_X_AWREADY: cross AW_READY, AW_VALID;
	W_VALID_X_W_READY: cross W_READY, W_VALID;
	B_VALID_X_B_READY: cross B_READY, B_VALID;
	W_VALID_X_W_READY_X_W_LAST: cross W_VALID, W_READY, W_LAST;
	W_LEN_X_W_BURST_SIZE: cross AW_LENGTH, AW_BURST_SIZE;
     endgroup

     covergroup master_dyn_write_covgrp0 with function sample(int i);
	WRITE_DATA: coverpoint master_cov_data0.WDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
							bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
							bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
							bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	W_STROBE: coverpoint master_cov_data0.WSTRB[i] {bins W_STRB ={1, 2, 3, 4, 8, 12, 14, 15};}
     endgroup


     covergroup master_dyn_read_covgrp0 with function sample(int i);
	READ_DATA: coverpoint master_cov_data0.RDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
						      bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
						      bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
						      bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	READ_RESP: coverpoint master_cov_data0.RRESP[i] {bins R_RESP={0,1,2,3};}
     endgroup

	  //Covergroup for Master 1
     covergroup master_covgrp1;
	option.per_instance = 0;
	
	AW_ID :   coverpoint master_cov_data1.AWID {bins first_id={[1:51]};
						  bins second_id={[52:103]};
						  bins third_id = {[104:154]};
						  bins fourth_id = {[155:205]};
						  bins fifth_id ={[206:255]}; }

	AW_ADDR: coverpoint master_cov_data1.AWADDR{bins first_slave = {[32'h4000_0000:32'h4000_0fff]};
						   bins second_slave ={[32'h4000_1000: 32'h4000_1fff]};
						   bins third_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AW_LENGTH: coverpoint master_cov_data1.AWLEN {bins fixed_type_awlen1={[1:255]} iff(master_cov_data1.AWBURST==2'b00);
						    bins incrm_type_awlen1={[1:255]}iff(master_cov_data1.AWBURST==2'b01);
							
						    bins wrap_type_awlen4 ={[1:255]}iff(master_cov_data1.AWBURST==2'b10);}
							
						 /*   bins fixed_type_awlen2={[52:103]} iff(master_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen3 = {[104:154]}iff(master_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen4= {[155:205]}iff(master_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen5 ={[206:255]}iff(master_cov_data1.AWBURST==2'b00);
						    bins incrm_type_awlen1={[1:51]}iff(master_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen2={[52:103]}iff(master_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen3 = {[104:154]}iff(master_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen4= {[155:205]}iff(master_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen5 ={[206:255]}iff(master_cov_data1.AWBURST==2'b01);
						    bins wrap_type_awlen1={1,3}iff(master_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen2 = {7,15}iff(master_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen3= {31,63}iff(master_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen4 ={127,255}iff(master_cov_data1.AWBURST==2'b10);}
						*/

	AW_BURST_SIZE: coverpoint master_cov_data1.AWSIZE {bins W_B_SIZE ={0,1,2};}

	AW_BURST_TYPE: coverpoint master_cov_data1.AWBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	AW_VALID: coverpoint master_cov_data1.AWVALID{ bins AWVALID ={0,1};}

	AW_READY:coverpoint master_cov_data1.AWREADY{bins AWREADY={0,1};}

	W_LAST:coverpoint master_cov_data1.WLAST{bins WLAST={0,1};}

	W_VALID: coverpoint master_cov_data1.WVALID{ bins WVALID ={0,1};}

	W_READY:coverpoint master_cov_data1.WREADY{bins WREADY={0,1};}

	B_ID :   coverpoint master_cov_data1.BID {bins first_id={[1:51]};
						bins second_id={[52:103]};
						bins third_id = {[104:154]};
						bins fourth_id = {[155:205]};
						bins fifth_id ={[206:255]}; }


	WRITE_RESP : coverpoint master_cov_data1.BRESP { bins W_RESP ={0,1,2,3}; }

	B_VALID: coverpoint master_cov_data1.BVALID{ bins BVALID ={0,1};}

	B_READY:coverpoint master_cov_data1.BREADY{bins BREADY ={0,1};}


	AR_ID: coverpoint master_cov_data1.ARID {bins first_id={[0:255]};}

	AR_ADDR: coverpoint master_cov_data1.ARADDR{ bins first_slave = {[32'h4000_0000:32'h4000_0fff]};
						   bins second_slave ={[32'h4000_1000: 32'h4000_1fff]};
						   bins third_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AR_LENGTH: coverpoint master_cov_data1.ARLEN {bins fixed_type_arlen1={[1:255]} iff(master_cov_data1.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:255]}iff(master_cov_data1.ARBURST==2'b01);
							
						    bins wrap_type_arlen4 ={[1:255]}iff(master_cov_data1.ARBURST==2'b10);}
							
						    /*bins fixed_type_arlen2={[52:103]} iff(master_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen3 = {[104:154]}iff(master_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen4= {[155:205]}iff(master_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen5 ={[206:255]}iff(master_cov_data1.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:51]}iff(master_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen2={[52:103]}iff(master_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen3 = {[104:154]}iff(master_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen4= {[155:205]}iff(master_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen5 ={[206:255]}iff(master_cov_data1.ARBURST==2'b01);
						    bins wrap_type_arlen1={1,3}iff(master_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen2 = {7,15}iff(master_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen3= {31,63}iff(master_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen4 ={127,255}iff(master_cov_data1.ARBURST==2'b10);}
						*/
	R_TRANSFER_SIZE: coverpoint master_cov_data1.ARSIZE { bins fixed_byte_transfer={0} iff(master_cov_data1.ARBURST==2'b00);
							  bins fixed_half_word_transfer={1} iff(master_cov_data1.ARBURST==2'b00);
							  bins fixed_word_transfer ={2} iff(master_cov_data1.ARBURST==2'b00);
 							  bins incrm_byte_transfer={0} iff(master_cov_data1.ARBURST==2'b01);
							  bins incrm_half_word_transfer={1} iff(master_cov_data1.ARBURST==2'b01);
							  bins incrm_word_transfer ={2} iff(master_cov_data1.ARBURST==2'b01);
 							  bins wrap_byte_transfer={0} iff(master_cov_data1.ARBURST==2'b10);
							  bins wrap_half_word_transfer={1} iff(master_cov_data1.ARBURST==2'b10);
							  bins wrap_word_transfer ={2} iff(master_cov_data1.ARBURST==2'b10);}

	AR_BURST_SIZE: coverpoint master_cov_data1.ARSIZE{bins R_B_SIZE ={0, 1, 2};}

	AR_BURST_TYPE: coverpoint master_cov_data1.ARBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	ARVALID: coverpoint master_cov_data1.ARVALID{bins ARVALID ={0,1};}

	ARREADY: coverpoint master_cov_data1.ARREADY{bins ARREADY={0,1};}

	R_ID: coverpoint master_cov_data1.RID {bins first_id={[0:255]};}

	R_LAST: coverpoint master_cov_data1.RLAST{bins RLAST ={0,1};}

	R_READY:coverpoint master_cov_data1.RREADY{bins RREADY ={0,1};}

	R_VALID: coverpoint master_cov_data1.RVALID{bins RVALID ={0,1};}

        // Cross Bins
	ARVALID_ARREADY: cross ARVALID, ARREADY;
	R_VALID_R_READY: cross R_READY, R_VALID;
	R_VALID_R_READY_RLAST: cross R_READY, R_VALID, R_LAST;
	R_LEN_X_R_BURST_SIZE: cross AR_LENGTH, AR_BURST_SIZE;


        // Cross Bins
	AW_VALID_X_AWREADY: cross AW_READY, AW_VALID;
	W_VALID_X_W_READY: cross W_READY, W_VALID;
	B_VALID_X_B_READY: cross B_READY, B_VALID;
	W_VALID_X_W_READY_X_W_LAST: cross W_VALID, W_READY, W_LAST;
	W_LEN_X_W_BURST_SIZE: cross AW_LENGTH, AW_BURST_SIZE;
     endgroup

     covergroup master_dyn_write_covgrp1 with function sample(int i);
	WRITE_DATA: coverpoint master_cov_data1.WDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
							bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
							bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
							bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	W_STROBE: coverpoint master_cov_data1.WSTRB[i] {bins W_STRB ={1, 2, 3, 4, 8, 12, 14, 15};}
     endgroup


     covergroup master_dyn_read_covgrp1 with function sample(int i);
	READ_DATA: coverpoint master_cov_data1.RDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
						      bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
						      bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
						      bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	READ_RESP: coverpoint master_cov_data1.RRESP[i] {bins R_RESP={0,1,2,3};}
     endgroup

     //--------------------------------------SLAVE COVERGROUPS-------------------------------------------//
     //Covergroup for Slave 0
     covergroup slave_covgrp0;
	option.per_instance = 0;

	AW_ID :   coverpoint slave_cov_data0.AWID {bins first_id={[1:51]};
						  bins second_id={[52:103]};
						  bins third_id = {[104:154]};
						  bins fourth_id = {[155:205]};
						  bins fifth_id ={[206:255]}; }

	AW_ADDR: coverpoint slave_cov_data0.AWADDR{ bins first_slave = {[32'h4000_0000:32'h4000_0fff]};}

	AW_LENGTH: coverpoint slave_cov_data0.AWLEN {bins fixed_type_awlen1={[1:51]} iff(slave_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen2={[52:103]} iff(slave_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen3 = {[104:154]}iff(slave_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen4= {[155:205]}iff(slave_cov_data0.AWBURST==2'b00);
						    bins fixed_type_awlen5 ={[206:255]}iff(slave_cov_data0.AWBURST==2'b00);
						    bins incrm_type_awlen1={[1:51]}iff(slave_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen2={[52:103]}iff(slave_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen3 = {[104:154]}iff(slave_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen4= {[155:205]}iff(slave_cov_data0.AWBURST==2'b01);
						    bins incrm_type_awlen5 ={[206:255]}iff(slave_cov_data0.AWBURST==2'b01);
						    bins wrap_type_awlen1={1,3}iff(slave_cov_data0.AWBURST==2'b10);
						    bins wrap_type_awlen2 = {7,15}iff(slave_cov_data0.AWBURST==2'b10);
						    bins wrap_type_awlen3= {31,63}iff(slave_cov_data0.AWBURST==2'b10);
						    bins wrap_type_awlen4 ={127,255}iff(slave_cov_data0.AWBURST==2'b10);}
	

	AW_BURST_SIZE: coverpoint slave_cov_data0.AWSIZE {bins W_B_SIZE ={0,1,2};}

	AW_BURST_TYPE: coverpoint slave_cov_data0.AWBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	AW_VALID: coverpoint slave_cov_data0.AWVALID{ bins AWVALID ={0,1};}

	AW_READY:coverpoint slave_cov_data0.AWREADY{bins AWREADY ={0,1};}

	W_LAST:coverpoint slave_cov_data0.WLAST{bins WLAST ={0,1};}

	W_VALID: coverpoint slave_cov_data0.WVALID{ bins WVALID ={0,1};}

	W_READY:coverpoint slave_cov_data0.WREADY{bins WREADY ={0,1};}

	B_ID :   coverpoint slave_cov_data0.BID {bins first_id={[1:51]};
						bins second_id={[52:103]};
						bins third_id = {[104:154]};
						bins fourth_id = {[155:205]};
						bins fifth_id ={[206:255]}; }


	WRITE_RESP : coverpoint slave_cov_data0.BRESP { bins W_RESP ={0,1,2,3}; }

	B_VALID: coverpoint slave_cov_data0.BVALID{ bins BVALID ={0,1};}

	B_READY:coverpoint slave_cov_data0.BREADY{bins BREADY ={0,1};}


	AR_ID: coverpoint slave_cov_data0.ARID {bins first_id={[0:255]};}

	AR_ADDR: coverpoint slave_cov_data0.ARADDR{  bins first_slave = {[32'h4000_0000:32'h4000_0fff]};}

	AR_LENGTH: coverpoint slave_cov_data0.ARLEN {bins fixed_type_arlen1={[1:51]} iff(slave_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen2={[52:103]} iff(slave_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen3 = {[104:154]}iff(slave_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen4= {[155:205]}iff(slave_cov_data0.ARBURST==2'b00);
						    bins fixed_type_arlen5 ={[206:255]}iff(slave_cov_data0.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:51]}iff(slave_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen2={[52:103]}iff(slave_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen3 = {[104:154]}iff(slave_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen4= {[155:205]}iff(slave_cov_data0.ARBURST==2'b01);
						    bins incrm_type_arlen5 ={[206:255]}iff(slave_cov_data0.ARBURST==2'b01);
						    bins wrap_type_arlen1={1,3}iff(slave_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen2 = {7,15}iff(slave_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen3= {31,63}iff(slave_cov_data0.ARBURST==2'b10);
						    bins wrap_type_arlen4 ={127,255}iff(slave_cov_data0.ARBURST==2'b10);}
	
	R_TRANSFER_SIZE: coverpoint slave_cov_data0.ARSIZE { bins fixed_byte_transfer={0} iff(slave_cov_data0.ARBURST==2'b00);
							  bins fixed_half_word_transfer={1} iff(slave_cov_data0.ARBURST==2'b00);
							  bins fixed_word_transfer ={2} iff(slave_cov_data0.ARBURST==2'b00);
 							  bins incrm_byte_transfer={0} iff(slave_cov_data0.ARBURST==2'b01);
							  bins incrm_half_word_transfer={1} iff(slave_cov_data0.ARBURST==2'b01);
							  bins incrm_word_transfer ={2} iff(slave_cov_data0.ARBURST==2'b01);
 							  bins wrap_byte_transfer={0} iff(slave_cov_data0.ARBURST==2'b10);
							  bins wrap_half_word_transfer={1} iff(slave_cov_data0.ARBURST==2'b10);
							  bins wrap_word_transfer ={2} iff(slave_cov_data0.ARBURST==2'b10);}

	AR_BURST_SIZE: coverpoint slave_cov_data0.ARSIZE{bins R_B_SIZE ={0, 1, 2};}

	AR_BURST_TYPE: coverpoint slave_cov_data0.ARBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	ARVALID: coverpoint slave_cov_data0.ARVALID{bins ARVALID ={0,1};}

	ARREADY: coverpoint slave_cov_data0.ARREADY{bins ARREADY={0,1};}

	R_ID: coverpoint slave_cov_data0.RID {bins first_id={[0:255]};}

	R_LAST: coverpoint slave_cov_data0.RLAST{bins RLAST ={0,1};}

	R_READY:coverpoint slave_cov_data0.RREADY{bins RREADY ={0,1};}

	R_VALID: coverpoint slave_cov_data0.RVALID{bins RVALID={0,1};}

        // Cross Bins
	ARVALID_ARREADY: cross ARVALID, ARREADY;
	R_VALID_R_READY: cross R_READY, R_VALID;
	R_VALID_R_READY_RLAST: cross R_READY, R_VALID, R_LAST;
	R_LEN_X_R_BURST_SIZE: cross AR_LENGTH, AR_BURST_SIZE;


        // Cross Bins
	AW_VALID_X_AWREADY: cross AW_READY, AW_VALID;
	W_VALID_X_W_READY: cross W_READY, W_VALID;
	B_VALID_X_B_READY: cross B_READY, B_VALID;
	W_VALID_X_W_READY_X_W_LAST: cross W_VALID, W_READY, W_LAST;
	W_LEN_X_W_BURST_SIZE: cross AW_LENGTH, AW_BURST_SIZE;
     endgroup

     covergroup slave_dyn_write_covgrp0 with function sample(int i);
	WRITE_DATA: coverpoint slave_cov_data0.WDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
							bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
							bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
							bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	W_STROBE: coverpoint slave_cov_data0.WSTRB[i] {bins W_STRB ={1, 2, 3, 4, 8, 12, 14, 15};}
     endgroup


     covergroup slave_dyn_read_covgrp0 with function sample(int i);
	READ_DATA: coverpoint slave_cov_data0.RDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
						      bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
						      bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
						      bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	READ_RESP: coverpoint slave_cov_data0.RRESP[i] {bins R_RESP={0,1,2,3};}
     endgroup

     //Covergroup for Slave 1
     covergroup slave_covgrp1;
	option.per_instance = 0;
	
	AW_ID :   coverpoint slave_cov_data1.AWID {bins first_id={[1:51]};
						  bins second_id={[52:103]};
						  bins third_id = {[104:154]};
						  bins fourth_id = {[155:205]};
						  bins fifth_id ={[206:255]}; }

	AW_ADDR: coverpoint slave_cov_data1.AWADDR{  bins first_slave = {[32'h4000_1000:32'h4000_1fff]};}

	AW_LENGTH: coverpoint slave_cov_data1.AWLEN {bins fixed_type_awlen1={[1:51]} iff(slave_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen2={[52:103]} iff(slave_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen3 = {[104:154]}iff(slave_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen4= {[155:205]}iff(slave_cov_data1.AWBURST==2'b00);
						    bins fixed_type_awlen5 ={[206:255]}iff(slave_cov_data1.AWBURST==2'b00);
						    bins incrm_type_awlen1={[1:51]}iff(slave_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen2={[52:103]}iff(slave_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen3 = {[104:154]}iff(slave_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen4= {[155:205]}iff(slave_cov_data1.AWBURST==2'b01);
						    bins incrm_type_awlen5 ={[206:255]}iff(slave_cov_data1.AWBURST==2'b01);
						    bins wrap_type_awlen1={1,3}iff(slave_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen2 = {7,15}iff(slave_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen3= {31,63}iff(slave_cov_data1.AWBURST==2'b10);
						    bins wrap_type_awlen4 ={127,255}iff(slave_cov_data1.AWBURST==2'b10);}
	

	AW_BURST_SIZE: coverpoint slave_cov_data1.AWSIZE {bins W_B_SIZE ={0,1,2};}

	AW_BURST_TYPE: coverpoint slave_cov_data1.AWBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	AW_VALID: coverpoint slave_cov_data1.AWVALID{ bins AWVALID ={0,1};}

	AW_READY:coverpoint slave_cov_data1.AWREADY{bins AWREADY={0,1};}

	W_LAST:coverpoint slave_cov_data1.WLAST{bins WLAST={0,1};}

	W_VALID: coverpoint slave_cov_data1.WVALID{ bins WVALID ={0,1};}

	W_READY:coverpoint slave_cov_data1.WREADY{bins WREADY={0,1};}

	B_ID :   coverpoint slave_cov_data1.BID {bins first_id={[1:51]};
						bins second_id={[52:103]};
						bins third_id = {[104:154]};
						bins fourth_id = {[155:205]};
						bins fifth_id ={[206:255]}; }


	WRITE_RESP : coverpoint slave_cov_data1.BRESP { bins W_RESP ={0,1,2,3}; }

	B_VALID: coverpoint slave_cov_data1.BVALID{ bins BVALID ={0,1};}

	B_READY:coverpoint slave_cov_data1.BREADY{bins BREADY ={0,1};}


	AR_ID: coverpoint slave_cov_data1.ARID {bins first_id={[0:255]};}

	AR_ADDR: coverpoint slave_cov_data1.ARADDR{  bins first_slave = {[32'h4000_1000:32'h4000_1fff]};}

	AR_LENGTH: coverpoint slave_cov_data1.ARLEN {bins fixed_type_arlen1={[1:51]} iff(slave_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen2={[52:103]} iff(slave_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen3 = {[104:154]}iff(slave_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen4= {[155:205]}iff(slave_cov_data1.ARBURST==2'b00);
						    bins fixed_type_arlen5 ={[206:255]}iff(slave_cov_data1.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:51]}iff(slave_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen2={[52:103]}iff(slave_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen3 = {[104:154]}iff(slave_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen4= {[155:205]}iff(slave_cov_data1.ARBURST==2'b01);
						    bins incrm_type_arlen5 ={[206:255]}iff(slave_cov_data1.ARBURST==2'b01);
						    bins wrap_type_arlen1={1,3}iff(slave_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen2 = {7,15}iff(slave_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen3= {31,63}iff(slave_cov_data1.ARBURST==2'b10);
						    bins wrap_type_arlen4 ={127,255}iff(slave_cov_data1.ARBURST==2'b10);}
	
	R_TRANSFER_SIZE: coverpoint slave_cov_data1.ARSIZE { bins fixed_byte_transfer={0} iff(slave_cov_data1.ARBURST==2'b00);
							  bins fixed_half_word_transfer={1} iff(slave_cov_data1.ARBURST==2'b00);
							  bins fixed_word_transfer ={2} iff(slave_cov_data1.ARBURST==2'b00);
 							  bins incrm_byte_transfer={0} iff(slave_cov_data1.ARBURST==2'b01);
							  bins incrm_half_word_transfer={1} iff(slave_cov_data1.ARBURST==2'b01);
							  bins incrm_word_transfer ={2} iff(slave_cov_data1.ARBURST==2'b01);
 							  bins wrap_byte_transfer={0} iff(slave_cov_data1.ARBURST==2'b10);
							  bins wrap_half_word_transfer={1} iff(slave_cov_data1.ARBURST==2'b10);
							  bins wrap_word_transfer ={2} iff(slave_cov_data1.ARBURST==2'b10);}

	AR_BURST_SIZE: coverpoint slave_cov_data1.ARSIZE{bins R_B_SIZE ={0, 1, 2};}

	AR_BURST_TYPE: coverpoint slave_cov_data1.ARBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	ARVALID: coverpoint slave_cov_data1.ARVALID{bins ARVALID ={0,1};}

	ARREADY: coverpoint slave_cov_data1.ARREADY{bins ARREADY ={0,1};}

	R_ID: coverpoint slave_cov_data1.RID {bins first_id={[0:255]};}

	R_LAST: coverpoint slave_cov_data1.RLAST{bins RLAST ={0,1};}

	R_READY:coverpoint slave_cov_data1.RREADY{bins RREADY ={0,1};}

	R_VALID: coverpoint slave_cov_data1.RVALID{bins RVALID={0,1};}

        // Cross Bins
	ARVALID_ARREADY: cross ARVALID, ARREADY;
	R_VALID_R_READY: cross R_READY, R_VALID;
	R_VALID_R_READY_RLAST: cross R_READY, R_VALID, R_LAST;
	R_LEN_X_R_BURST_SIZE: cross AR_LENGTH, AR_BURST_SIZE;


        // Cross Bins
	AW_VALID_X_AWREADY: cross AW_READY, AW_VALID;
	W_VALID_X_W_READY: cross W_READY, W_VALID;
	B_VALID_X_B_READY: cross B_READY, B_VALID;
	W_VALID_X_W_READY_X_W_LAST: cross W_VALID, W_READY, W_LAST;
	W_LEN_X_W_BURST_SIZE: cross AW_LENGTH, AW_BURST_SIZE;
     endgroup

     covergroup slave_dyn_write_covgrp1 with function sample(int i);
	WRITE_DATA: coverpoint slave_cov_data1.WDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
							bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
							bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
							bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	W_STROBE: coverpoint slave_cov_data1.WSTRB[i] {bins W_STRB ={1, 2, 3, 4, 8, 12, 14, 15};}
     endgroup


     covergroup slave_dyn_read_covgrp1 with function sample(int i);
	READ_DATA: coverpoint slave_cov_data1.RDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
						      bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
						      bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
						      bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	READ_RESP: coverpoint slave_cov_data1.RRESP[i] {bins R_RESP={0,1,2,3};}
     endgroup


     //Covergroup for Slave 2
     covergroup slave_covgrp2;
	option.per_instance = 0;
	
	AW_ID :   coverpoint slave_cov_data2.AWID {bins first_id={[1:51]};
						  bins second_id={[52:103]};
						  bins third_id = {[104:154]};
						  bins fourth_id = {[155:205]};
						  bins fifth_id ={[206:255]}; }

	AW_ADDR: coverpoint slave_cov_data2.AWADDR{bins first_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AW_LENGTH: coverpoint slave_cov_data2.AWLEN {bins fixed_type_awlen1={[1:51]} iff(slave_cov_data2.AWBURST==2'b00);
						    bins fixed_type_awlen2={[52:103]} iff(slave_cov_data2.AWBURST==2'b00);
						    bins fixed_type_awlen3 = {[104:154]}iff(slave_cov_data2.AWBURST==2'b00);
						    bins fixed_type_awlen4= {[155:205]}iff(slave_cov_data2.AWBURST==2'b00);
						    bins fixed_type_awlen5 ={[206:255]}iff(slave_cov_data2.AWBURST==2'b00);
						    bins incrm_type_awlen1={[1:51]}iff(slave_cov_data2.AWBURST==2'b01);
						    bins incrm_type_awlen2={[52:103]}iff(slave_cov_data2.AWBURST==2'b01);
						    bins incrm_type_awlen3 = {[104:154]}iff(slave_cov_data2.AWBURST==2'b01);
						    bins incrm_type_awlen4= {[155:205]}iff(slave_cov_data2.AWBURST==2'b01);
						    bins incrm_type_awlen5 ={[206:255]}iff(slave_cov_data2.AWBURST==2'b01);
						    bins wrap_type_awlen1={1,3}iff(slave_cov_data2.AWBURST==2'b10);
						    bins wrap_type_awlen2 = {7,15}iff(slave_cov_data2.AWBURST==2'b10);
						    bins wrap_type_awlen3= {31,63}iff(slave_cov_data2.AWBURST==2'b10);
						    bins wrap_type_awlen4 ={127,255}iff(slave_cov_data2.AWBURST==2'b10);}
	

	AW_BURST_SIZE: coverpoint slave_cov_data2.AWSIZE {bins W_B_SIZE ={0,1,2};}

	AW_BURST_TYPE: coverpoint slave_cov_data2.AWBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	AW_VALID: coverpoint slave_cov_data2.AWVALID{ bins AWVALID ={0,1};}

	AW_READY:coverpoint slave_cov_data2.AWREADY{bins AWREADY={0,1};}

	W_LAST:coverpoint slave_cov_data2.WLAST{bins WLAST={0,1};}

	W_VALID: coverpoint slave_cov_data2.WVALID{ bins WVALID ={0,1};}

	W_READY:coverpoint slave_cov_data2.WREADY{bins WREADY={0,1};}

	B_ID :   coverpoint slave_cov_data2.BID {bins first_id={[1:51]};
						bins second_id={[52:103]};
						bins third_id = {[104:154]};
						bins fourth_id = {[155:205]};
						bins fifth_id ={[206:255]}; }


	WRITE_RESP : coverpoint slave_cov_data2.BRESP { bins W_RESP ={0,1,2,3}; }

	B_VALID: coverpoint slave_cov_data2.BVALID{ bins BVALID ={0,1};}

	B_READY:coverpoint slave_cov_data2.BREADY{bins BREADY ={0,1};}


	AR_ID: coverpoint slave_cov_data2.ARID {bins first_id={[0:255]};}

	AR_ADDR: coverpoint slave_cov_data2.ARADDR{bins first_slave = {[32'h4000_2000:32'h4000_2fff]};}

	AR_LENGTH: coverpoint slave_cov_data2.ARLEN {bins fixed_type_arlen1={[1:51]} iff(slave_cov_data2.ARBURST==2'b00);
						    bins fixed_type_arlen2={[52:103]} iff(slave_cov_data2.ARBURST==2'b00);
						    bins fixed_type_arlen3 = {[104:154]}iff(slave_cov_data2.ARBURST==2'b00);
						    bins fixed_type_arlen4= {[155:205]}iff(slave_cov_data2.ARBURST==2'b00);
						    bins fixed_type_arlen5 ={[206:255]}iff(slave_cov_data2.ARBURST==2'b00);
						    bins incrm_type_arlen1={[1:51]}iff(slave_cov_data2.ARBURST==2'b01);
						    bins incrm_type_arlen2={[52:103]}iff(slave_cov_data2.ARBURST==2'b01);
						    bins incrm_type_arlen3 = {[104:154]}iff(slave_cov_data2.ARBURST==2'b01);
						    bins incrm_type_arlen4= {[155:205]}iff(slave_cov_data2.ARBURST==2'b01);
						    bins incrm_type_arlen5 ={[206:255]}iff(slave_cov_data2.ARBURST==2'b01);
						    bins wrap_type_arlen1={1,3}iff(slave_cov_data2.ARBURST==2'b10);
						    bins wrap_type_arlen2 = {7,15}iff(slave_cov_data2.ARBURST==2'b10);
						    bins wrap_type_arlen3= {31,63}iff(slave_cov_data2.ARBURST==2'b10);
						    bins wrap_type_arlen4 ={127,255}iff(slave_cov_data2.ARBURST==2'b10);}
	
	R_TRANSFER_SIZE: coverpoint slave_cov_data2.ARSIZE { bins fixed_byte_transfer={0} iff(slave_cov_data2.ARBURST==2'b00);
							  bins fixed_half_word_transfer={1} iff(slave_cov_data2.ARBURST==2'b00);
							  bins fixed_word_transfer ={2} iff(slave_cov_data2.ARBURST==2'b00);
 							  bins incrm_byte_transfer={0} iff(slave_cov_data2.ARBURST==2'b01);
							  bins incrm_half_word_transfer={1} iff(slave_cov_data2.ARBURST==2'b01);
							  bins incrm_word_transfer ={2} iff(slave_cov_data2.ARBURST==2'b01);
 							  bins wrap_byte_transfer={0} iff(slave_cov_data2.ARBURST==2'b10);
							  bins wrap_half_word_transfer={1} iff(slave_cov_data2.ARBURST==2'b10);
							  bins wrap_word_transfer ={2} iff(slave_cov_data2.ARBURST==2'b10);}

	AR_BURST_SIZE: coverpoint slave_cov_data2.ARSIZE{bins R_B_SIZE ={0, 1, 2};}

	AR_BURST_TYPE: coverpoint slave_cov_data2.ARBURST {bins fixed_type ={0};
							  bins incrm_type ={1};
							  bins wrap_type ={2};}

	ARVALID: coverpoint slave_cov_data2.ARVALID{bins ARVALID ={0,1};}

	ARREADY: coverpoint slave_cov_data2.ARREADY{bins ARREADY ={0,1};}

	R_ID: coverpoint slave_cov_data2.RID {bins first_id={[0:255]};}

	R_LAST: coverpoint slave_cov_data2.RLAST{bins RLAST ={0,1};}

	R_READY:coverpoint slave_cov_data2.RREADY{bins RREADY ={0,1};}

	R_VALID: coverpoint slave_cov_data2.RVALID{bins RVALID ={0,1};}

        // Cross Bins
	ARVALID_ARREADY: cross ARVALID, ARREADY;
	R_VALID_R_READY: cross R_READY, R_VALID;
	R_VALID_R_READY_RLAST: cross R_READY, R_VALID, R_LAST;
	R_LEN_X_R_BURST_SIZE: cross AR_LENGTH, AR_BURST_SIZE;


        // Cross Bins
	AW_VALID_X_AWREADY: cross AW_READY, AW_VALID;
	W_VALID_X_W_READY: cross W_READY, W_VALID;
	B_VALID_X_B_READY: cross B_READY, B_VALID;
	W_VALID_X_W_READY_X_W_LAST: cross W_VALID, W_READY, W_LAST;
	W_LEN_X_W_BURST_SIZE: cross AW_LENGTH, AW_BURST_SIZE;
     endgroup

     covergroup slave_dyn_write_covgrp2 with function sample(int i);
	WRITE_DATA: coverpoint slave_cov_data2.WDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
							bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
							bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
							bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	W_STROBE: coverpoint slave_cov_data2.WSTRB[i] {bins W_STRB ={1, 2, 3, 4, 8, 12, 14, 15};}
     endgroup


     covergroup slave_dyn_read_covgrp2 with function sample(int i);
	READ_DATA: coverpoint slave_cov_data2.RDATA[i] {bins low = {[32'h0000_0000:32'h4444_4444]};
						      bins mid1 ={[32'h4444_4445: 32'h8888_8888]};
						      bins mid2 = {[32'h8888_8889:32'hcccc_cccc]};
						      bins high ={[32'hcccc_cccd:32'hffff_ffff]};}

	READ_RESP: coverpoint slave_cov_data2.RRESP[i] {bins R_RESP={0,1,2,3};}
     endgroup



    // Methods
    extern function new(string name="scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void check_data(master_xtn mast_master_xtn, master_xtn slv_master_xtn);
    extern function void report_phase(uvm_phase phase);

 endclass

 function scoreboard :: new(string name="scoreboard", uvm_component parent);
    super.new(name, parent);
    rst_cov_data=new();
    master_cov_data0 = new();
    slave_cov_data0 = new();
    master_cov_data1 = new();
    slave_cov_data1 = new();
    slave_cov_data2 = new();
    master_covgrp0 = new();
    slave_covgrp0 = new();
    master_covgrp1 = new();
    slave_covgrp1 = new();
    slave_covgrp2 = new();
    master_dyn_write_covgrp0 = new();
    slave_dyn_write_covgrp0=new();
    master_dyn_write_covgrp1 = new();
    slave_dyn_write_covgrp1=new();
    slave_dyn_write_covgrp2=new();
    master_dyn_read_covgrp0 = new();
    slave_dyn_read_covgrp0=new();
    master_dyn_read_covgrp1 = new();
    slave_dyn_read_covgrp1=new();
    slave_dyn_read_covgrp2=new();

 endfunction

 function void scoreboard :: build_phase(uvm_phase phase);
    super.build_phase(phase);
	
    	if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfg))
			`uvm_fatal("scoreboard","getting config failed")

		master_fifoh=new[env_cfg.no_of_master_agents];
		slave_fifoh=new[env_cfg.no_of_slave_agents];
		reset_fifoh=new[env_cfg.no_of_reset_agents];

		foreach(master_fifoh[i])
		begin
			master_fifoh[i]=new($sformatf("master_fifoh[%0d]",i),this);
		end

		foreach(slave_fifoh[i])
		begin
			slave_fifoh[i]=new($sformatf("slave_fifoh[%0d]",i),this);
		end
		
		foreach(reset_fifoh[i])
		begin
			reset_fifoh[i]=new($sformatf("reset_fifoh[%0d]",i),this);
		end
 endfunction


    task scoreboard :: run_phase(uvm_phase phase);
      fork
        //-------------------------------------------------
        // MASTER TRANSACTION COLLECTOR
        //-------------------------------------------------
          forever 
            begin
                // --- Master 0 Collector ---
                  master_xtn mast_data_local; // Use a local handle
                  master_fifoh[0].get(mast_data_local);
                  `uvm_info("AXI_SB_MAS_0", "Master 0 Txn Received", UVM_LOW)
                  //mast_data_local.print();

                  // Store in pending queue based on ID
                  if (mast_data_local.AWVALID && mast_data_local.AWREADY)
                    m_write_pending[mast_data_local.AWID].push_back(mast_data_local);
                     
                  if (mast_data_local.ARVALID && mast_data_local.ARREADY)
                    m_read_pending[mast_data_local.ARID].push_back(mast_data_local);

                  // --- Handle Coverage ---
                  master_cov_data0 = mast_data_local;
                  master_covgrp0.sample();
                  if (mast_data_local.AWVALID && mast_data_local.AWREADY)
                    foreach(master_cov_data0.WDATA[i])
                      master_dyn_write_covgrp0.sample(i);

                  if (mast_data_local.ARVALID && mast_data_local.ARREADY)
                    foreach(master_cov_data0.RDATA[i])
                      master_dyn_read_covgrp0.sample(i);
                end

                // --- Master 1 Collector ---
              forever
                begin
                  master_xtn mast_data_local1; // Use a local handle
                  master_fifoh[1].get(mast_data_local1);
                  `uvm_info("AXI_SB_MAS_1", "Master 1 Txn Received", UVM_LOW)
                  //mast_data_local.print();

                  // Store in pending queue based on ID
                  if (mast_data_local1.AWVALID && mast_data_local1.AWREADY)
                    m_write_pending[mast_data_local1.AWID].push_back(mast_data_local1);
    
                  if (mast_data_local1.ARVALID && mast_data_local1.ARREADY)
                    m_read_pending[mast_data_local1.ARID].push_back(mast_data_local1);

                  // --- Handle Coverage ---
                  master_cov_data1 = mast_data_local1;
                  master_covgrp1.sample();
                  //if (mast_data_local.AWVALID)
                    foreach(master_cov_data1.WDATA[i])
                      master_dyn_write_covgrp1.sample(i);

                  //if (mast_data_local.ARVALID)
                    foreach(master_cov_data1.RDATA[i])
                      master_dyn_read_covgrp1.sample(i);
                end
		
        //-------------------------------------------------
        // SLAVE TRANSACTION COLLECTOR & COMPARATOR
        //-------------------------------------------------
          forever 
            begin
                // --- Slave 0 Comparator ---
                  master_xtn slv_data_local;
                  master_xtn mast_data_match;
                  int id;

                  slave_fifoh[0].get(slv_data_local);
                  `uvm_info("AXI_SB_SLV_0", "Slave 0 Txn Received", UVM_LOW)
                  //slv_data_local.print();
              
                  // Find matching master transaction based on ID
                  if (slv_data_local.AWVALID && slv_data_local.AWREADY) 
                    begin // It's a Write Transaction
                      id = slv_data_local.AWID;
                      // Wait for the matching master txn to arrive
                      wait(m_write_pending.exists(id) && m_write_pending[id].size() > 0);
                      mast_data_match = m_write_pending[id].pop_front();
                    end
 
                  if (slv_data_local.ARVALID && slv_data_local.ARREADY) 
                    begin // It's a Read Transaction
                      id = slv_data_local.ARID;
                      // Wait for the matching master txn to arrive
                      wait(m_read_pending.exists(id) && m_read_pending[id].size() > 0);
                      mast_data_match = m_read_pending[id].pop_front();
                    end

                  // Check address routing (from your original logic)
                  if(slv_data_local.AWVALID && slv_data_local.AWREADY)
                    if (!((slv_data_local.AWADDR >= 32'h4000_0000) && (slv_data_local.AWADDR <= 32'h4000_0FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Write Address is out of range")

                  // Check address routing (from your original logic)
                  if(slv_data_local.ARVALID && slv_data_local.ARREADY)
                    if (!((slv_data_local.ARADDR >= 32'h4000_0000) && (slv_data_local.ARADDR <= 32'h4000_0FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Read Address is out of range")

							
                    // Perform the comparison
                    check_data(mast_data_match, slv_data_local); // Pass BOTH transactions

                    // --- Handle Coverage ---
                    slave_cov_data0 = slv_data_local;
                    slave_covgrp0.sample();
                    if(slv_data_local.RVALID && slv_data_local.RREADY)
                      foreach(slave_cov_data0.RDATA[i])
                        slave_dyn_read_covgrp0.sample(i);	

                    if(slv_data_local.WVALID && slv_data_local.WREADY)
                      foreach(slave_cov_data0.WDATA[i])			
                        slave_dyn_write_covgrp0.sample(i);	
                end

                // --- Slave 1 Comparator ---
              forever
                begin
                  master_xtn slv_data_local1;
                  master_xtn mast_data_match1;
                  int id;

                  slave_fifoh[1].get(slv_data_local1);
                  `uvm_info("AXI_SB_SLV_1", "Slave 1 Txn Received", UVM_LOW)
                  slv_data_local1.print();

                  // Find matching master transaction based on ID
                  if (slv_data_local1.AWVALID && slv_data_local1.AWREADY) 
                    begin
                      id = slv_data_local1.AWID;
                      wait(m_write_pending.exists(id) && m_write_pending[id].size() > 0); 
                      mast_data_match1 = m_write_pending[id].pop_front();
                    end 

                  if (slv_data_local1.ARVALID && slv_data_local1.ARREADY) 
                    begin
                      id = slv_data_local1.ARID;
                      wait(m_read_pending.exists(id) && m_read_pending[id].size() > 0);
                      mast_data_match1 = m_read_pending[id].pop_front();
                    end
              
                  // Check address routing (from your original logic)
                  if(slv_data_local1.AWVALID && slv_data_local1.AWREADY)
                    if (!((slv_data_local1.AWADDR >= 32'h4000_1000) && (slv_data_local1.AWADDR <= 32'h4000_1FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Write Address is out of range")

                  // Check address routing (from your original logic)
                  if(slv_data_local1.ARVALID && slv_data_local1.ARREADY)
                    if (!((slv_data_local1.ARADDR >= 32'h4000_1000) && (slv_data_local1.ARADDR <= 32'h4000_1FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Read Address is out of range")

                  check_data(mast_data_match1, slv_data_local1);

                  slave_cov_data1 = slv_data_local1;
                  slave_covgrp1.sample();
                  if(slv_data_local1.RVALID && slv_data_local1.RREADY)
                    foreach(slave_cov_data1.RDATA[i])
                      slave_dyn_read_covgrp1.sample(i);	

                  if(slv_data_local1.WVALID && slv_data_local1.WREADY)
                    foreach(slave_cov_data1.WDATA[i])
                      slave_dyn_write_covgrp1.sample(i);	
                end	

                // --- Slave 2 Comparator ---
              forever
                begin
                  master_xtn slv_data_local2;
                  master_xtn mast_data_match2;
                  int id;

                  slave_fifoh[2].get(slv_data_local2);
                  `uvm_info("AXI_SB_SLV_2", "Slave 2 Txn Received", UVM_LOW)
                  slv_data_local2.print();

                  // Find matching master transaction based on ID
                  if (slv_data_local2.AWVALID && slv_data_local2.AWREADY) 
                    begin
                      id = slv_data_local2.AWID;
                      wait(m_write_pending.exists(id) && m_write_pending[id].size() > 0);
                      mast_data_match2 = m_write_pending[id].pop_front();
                    end 

                  if (slv_data_local2.ARVALID && slv_data_local2.ARREADY) 
                    begin
                      id = slv_data_local2.ARID;
                      wait(m_read_pending.exists(id) && m_read_pending[id].size() > 0);
                      mast_data_match2 = m_read_pending[id].pop_front();
                    end
              
                  // Check address routing (from your original logic)
                  if(slv_data_local2.AWVALID && slv_data_local2.AWREADY)
                    if (!((slv_data_local2.AWADDR >= 32'h4000_2000) && (slv_data_local2.AWADDR <= 32'h4000_2FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Write Address is out of range")

                  // Check address routing (from your original logic)
                  if(slv_data_local2.ARVALID && slv_data_local2.ARREADY)
                    if (!((slv_data_local2.ARADDR >= 32'h4000_2000) && (slv_data_local2.ARADDR <= 32'h4000_2FFF))) 
                      `uvm_error("SCORE_BOARD-0", "Data from Slave 0: Read Address is out of range")

                  check_data(mast_data_match2, slv_data_local2);

                  slave_cov_data2 = slv_data_local2;
                  slave_covgrp2.sample();
                  if(slv_data_local2.RVALID && slv_data_local2.RREADY)
                    foreach(slave_cov_data2.RDATA[i])
                      slave_dyn_read_covgrp2.sample(i);	

                  //if(slv_data_local2.WVALID && slv_data_local2.WREADY)
                    foreach(slave_cov_data2.WDATA[i])
                      slave_dyn_write_covgrp2.sample(i);	
                end
      join
    endtask


function void scoreboard :: check_data(master_xtn mast_master_xtn, master_xtn slv_master_xtn);
    $display("******************************************** Report from Scoreboard ***************************************************");
	
    //mast_master_xtn = q1.pop_front();
	
    if(mast_master_xtn.AWVALID && mast_master_xtn.AWREADY)
      begin

	 if(mast_master_xtn.AWADDR == slv_master_xtn.AWADDR)
	    `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Address comparision is Successful", UVM_LOW)
	 else
           begin
	    `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Address comparision is Failed")
             $display("master address= %h, slave address = %h",mast_master_xtn.AWADDR,slv_master_xtn.AWADDR);
             pass=0;
           end

	 if(mast_master_xtn.AWLEN == slv_master_xtn.AWLEN)
	 if(mast_master_xtn.AWSIZE == slv_master_xtn.AWSIZE)
	 if(mast_master_xtn.AWBURST == slv_master_xtn.AWBURST)
	    `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Control information comparision is Successful", UVM_LOW)
	 else
           begin
	    `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Control information comparision is Failed")
             pass=0;
           end
        end

       if(mast_master_xtn.WVALID && mast_master_xtn.WREADY)
         begin
	 foreach(slv_master_xtn.WDATA[i])
	    if(mast_master_xtn.WDATA[i] ==slv_master_xtn.WDATA[i])
	       `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Data comparision is Successful", UVM_LOW)
	    else
              begin
	       `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Data comparision is Failed")
                $display("master data= %h, slave data = %h",mast_master_xtn.WDATA[i],slv_master_xtn.WDATA[i]);
                pass=0;
              end

	 foreach(slv_master_xtn.WSTRB[i])
	    if(mast_master_xtn.WSTRB[i] == slv_master_xtn.WSTRB[i])
	 	`uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Strobe comparision is Successful", UVM_LOW)
		else
                  begin
		    `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Strobe comparision is Failed")
                    pass=0;
                  end
          end

       if(mast_master_xtn.BVALID && mast_master_xtn.BREADY)
        begin
	 if(mast_master_xtn.BRESP == slv_master_xtn.BRESP)
	 	`uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Response comparision is Successful", UVM_LOW)
    	 else
           begin
		`uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Response comparision is Failed")
                 pass=0;
           end

         if(mast_master_xtn.BID == slv_master_xtn.BID)
            `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID comparision is Successful", UVM_LOW)
         else
           begin
            `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID comparision is Failed")
             $display("master bid= %h, slave bid = %h",mast_master_xtn.BID,slv_master_xtn.BID);
             pass=0;
           end

         if(mast_master_xtn.AWID == slv_master_xtn.BID)
            `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID with transfer ID comparision is Successful", UVM_LOW)
         else
           begin
            `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID with transfer ID comparision is Failed")
             $display("master awid= %h, slave bid = %h",mast_master_xtn.AWID,slv_master_xtn.BID);
             pass=0;
           end 

        end

	$display("=====================================SB pg 1096======================================");
    if(mast_master_xtn.ARVALID && mast_master_xtn.ARREADY)
      begin
        $display("^^^^^^^^^^^^^^^^^^^^^^ Score Board Read-Transaction Comparision ^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

	if(mast_master_xtn.ARADDR == slv_master_xtn.ARADDR)
	   `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read Address comparision is Successful", UVM_LOW)
	else
          begin
	   `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read Address comparision is Failed")
            pass=0;
          end

	if(mast_master_xtn.ARLEN == slv_master_xtn.ARLEN)
	if(mast_master_xtn.ARSIZE == slv_master_xtn.ARSIZE)
	if(mast_master_xtn.ARBURST == slv_master_xtn.ARBURST)
	    `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read Control information comparision is Successful", UVM_LOW)
	else
          begin
	    `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read Control information comparision is Failed")
            pass=0;
          end
       end

      if(mast_master_xtn.RVALID && mast_master_xtn.RREADY)
       begin
	foreach(slv_master_xtn.RDATA[i])
	    if(mast_master_xtn.RDATA[i] ==slv_master_xtn.RDATA[i])
	       `uvm_info("AXI_SCORE-BOARD--Read_DATA", "Read Data comparision is Successful", UVM_LOW)
	    else
              begin
	       `uvm_error("AXI_SCORE-BOARD--Read_DATA", "Read Data comparision is Failed")
                pass=0;
              end

 	foreach(slv_master_xtn.RRESP[i])
	    if(mast_master_xtn.RRESP[i] ==slv_master_xtn.RRESP[i])
	 	`uvm_info("AXI_SCORE-BOARD--Read_DATA", "Read Response comparision is Successful", UVM_LOW)
	    else
              begin
		`uvm_error("AXI_SCORE-BOARD--Read_DATA", "Read Response comparision is Failed")
                 pass=0;
              end

         if(mast_master_xtn.RID == slv_master_xtn.RID)
            `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read response ID comparision is Successful", UVM_LOW)
         else
           begin
            `uvm_error("AXI_SCORE-BOARD--Read_DATA", "Read response ID comparision is Failed")
             $display("master rid= %h, slave rid = %h",mast_master_xtn.RID,slv_master_xtn.RID);
             pass=0;
           end

         if(mast_master_xtn.ARID == slv_master_xtn.RID)
            `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read response ID with transfer ID comparision is Successful", UVM_LOW)
         else
           begin
            `uvm_error("AXI_SCORE-BOARD--Read_DATA", "Read response ID with transfer ID comparision is Failed")
             $display("master arid= %h, slave rid = %h",mast_master_xtn.ARID,slv_master_xtn.RID);
             pass=0;
           end

                 $display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
      end

     data_verified_count++;
     $display("*******************************************************************************************************************");	

 endfunction



  function void scoreboard::report_phase(uvm_phase phase);

    // Check for any master transactions that were never matched by a slave
    foreach (m_write_pending[i]) 
      begin
        if (m_write_pending[i].size() > 0) 
          begin
            `uvm_error("AXI_SB_REPORT", $sformatf("Found %0d un-matched master WRITE transactions with ID %0h", m_write_pending[i].size(), i))
            pass = 0;
          end
      end

    foreach (m_read_pending[i]) 
      begin
        if (m_read_pending[i].size() > 0) 
          begin
            `uvm_error("AXI_SB_REPORT", $sformatf("Found %0d un-matched master READ transactions with ID %0h", m_read_pending[i].size(), i))
            pass = 0;
          end
      end

    if(pass)
      begin
               $display("================================================Success=============================================================");
        end

    else
      begin
		$display("===============================================================FAIL====================================================");

        end

  endfunction
     
