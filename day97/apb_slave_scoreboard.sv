`include "uvm_macros.svh"

import uvm_pkg::*;

class apb_slave_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(apb_slave_scoreboard);
  
  // TODO: Model RV32I operations here
  bit [31:0] regfile;
  // DMEM
  riscv_tb_mem dmem;
  
  uvm_analysis_imp #(apb_slave_item, apb_slave_scoreboard) m_analysis_imp;
  
  function new (string name="apb_slave_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("apb_slave_imp", this);
    // Get the handle to memory
    if (!uvm_config_db#(riscv_tb_mem)::get(null, "", "riscv_tb_mem", dmem)) begin
      `uvm_fatal("SCBD", "Could not get the handle to the memory");
    end
  endfunction
  
  // Implement the write function
  virtual function write (apb_slave_item item);
    logic [31:0] mem_data;
    `uvm_info("SCOREBOARD", "Got a new transaction", UVM_LOW)
    // Write data into the memory on a write
    if (item.dmem_psel & item.dmem_penable & item.dmem_pwrite & item.dmem_pready) begin
      dmem.write(item.dmem_paddr, item.dmem_pwdata);
    end
    // Read data from memory on a read
    if (item.dmem_psel & item.dmem_penable & ~item.dmem_pwrite & item.dmem_pready) begin
      mem_data = dmem.read(item.dmem_paddr);
      if (mem_data !== item.dmem_prdata) begin
        `uvm_fatal("[SCOREBOARD]", $sformatf("Read data mismatch. Expected data: 0x%x, Got: 0x%x", mem_data, item.dmem_prdata))
      end
    end
  endfunction
  
endclass