
   `timescale 1ns / 1ps
   interface reset_interface(input bit clk);
     logic reset;

       clocking rst_drv_cb @(posedge clk);
           output reset;
       endclocking

       clocking rst_mon_cb @(posedge clk);
           input reset;
       endclocking

       modport RST_DRV_MP(clocking rst_drv_cb);
       modport RST_MON_MP(clocking rst_mon_cb);
    endinterface
