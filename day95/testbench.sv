// UVM Testbench for APB Master RTL
// Declare package to include all the files
`include "riscv_tb_pkg.sv"
package apb_slave_pkg;

	`include "apb_slave_item.sv"
	`include "apb_slave_basic_seq.sv"
	`include "apb_slave_driver.sv"
	`include "apb_slave_monitor.sv"
	`include "apb_slave_agent.sv"
	`include "apb_slave_scoreboard.sv"
	`include "apb_slave_env.sv"
	`include "apb_slave_test.sv"

endpackage

`include "uvm_macros.svh"

import uvm_pkg::*;
import apb_slave_pkg::*;
import riscv_tb_pkg::*;
`include "apb_intf.sv"

module top ();
  
  logic		clk;
  logic		reset;
  
  // Instantiate RTL
  riscv_top RISCV (
    .clk					(clk),
    .reset					(reset),
    
    .imem_psel_o			(apb_slave_intf.psel),
    .imem_penable_o			(apb_slave_intf.penable),
    .imem_paddr_o			(apb_slave_intf.paddr),
    .imem_pwrite_o			(apb_slave_intf.pwrite),
    .imem_pwdata_o			(apb_slave_intf.pwdata),
    .imem_pready_i			(apb_slave_intf.pready),
    .imem_prdata_i			(apb_slave_intf.prdata),
    
    .dmem_psel_o			(),
    .dmem_penable_o			(),
    .dmem_paddr_o			(),
    .dmem_pwrite_o			(),
    .dmem_pwdata_o			(),
    .dmem_pready_i			(),
    .dmem_prdata_i			()
  );
  
  // Physical interface
  apb_slave_if apb_slave_intf (clk, reset);
  
  // Initialise registers
  initial begin
    for (int i=0; i<32; i++) begin
      RISCV.REGFILE.reg_file[i] = 32'(i);
    end 
  end
  
  // Generate clock
  always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
  end
  
  // Generate reset sequence and start the test
  initial begin
    reset = 1'b1;
    @(posedge clk);
    reset = 1'b0;
  end
  
  initial begin
    // Set the interface handle
    uvm_config_db#(virtual apb_slave_if)::set(null, "*", "apb_slave_vif", apb_slave_intf);
    `uvm_info("TOP", "apb_slave_vif set in the configdb", UVM_LOW)
    run_test ("apb_slave_test");
    #200;
    $finish();
  end
  
  initial begin
    $dumpfile ("apb_slave_tb.vcd");
    $dumpvars (0, top);
  end
  
endmodule