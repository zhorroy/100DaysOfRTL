`include "uvm_macros.svh"

import uvm_pkg::*;

class apb_slave_env extends uvm_env;
  
  `uvm_component_utils (apb_slave_env);
  
  apb_slave_agent 			a0;
  apb_slave_scoreboard		sb0;
  
  function new (string name="apb_slave_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Create agent and scoreboard in the build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    a0 = apb_slave_agent::type_id::create("a0", this);
    sb0 = apb_slave_scoreboard::type_id::create("sb0", this);
  endfunction
  
  // Connect monitor analysis export with scoreboar
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
  endfunction
  
endclass