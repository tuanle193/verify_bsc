class apb_transaction extends uvm_sequence_item;
//   `uvm_object_utils(apb_transaction)

  // --------------------------
  // Parameters
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter PSTRB_WIDTH = 4;
  // --------------------------
  rand bit PRESETn;
  rand bit [ADDR_WIDTH-1:0]  PADDR;         // Address
  rand bit         PWRITE;        // 1: Write, 0: Read
  rand bit [DATA_WIDTH-1:0]  PWDATA;        // Write Data
  rand bit [PSTRB_WIDTH-1:0]   PSTRB;         // Byte enable strobe (4 bits for 32-bit data)
       bit [DATA_WIDTH-1:0]  PRDATA;        // Read Data (from DUT)

  // Parity check result from slave
       bit [PSTRB_WIDTH-1:0]       PADDRCHK;
       bit [PSTRB_WIDTH-1:0]       PWDATACHK;
       bit         PSTRBCHK;  // Strobe parity check from slave

  // Parity bit from slave for PRDATA
       bit [PSTRB_WIDTH-1:0]    PRDATACHK;

  // Handshake & response
       bit         PREADY;
       bit         PSLVERR;

  // Optional delay
//  rand int         wait_cycles;
/*
  constraint default_c {
    wait_cycles inside {[0:5]};
  }
  */

  // Function to calculate parity for address (even parity per byte)
  function bit [3:0] calc_addr_parity(bit [31:0] PADDR);
    bit [3:0] parity;
    for (int i = 0; i < 4; i++) begin
      parity[i] =~(^PADDR[i*8 +: 8]); // XOR all bits in each byte
    end
    return parity;
  endfunction

  // Function to calculate parity for write data (even parity per byte)
  function bit [3:0] calc_wdata_parity(bit [31:0] PWDATA);
    bit [3:0] parity;
    for (int i = 0; i < 4; i++) begin
      parity[i] =~(^PWDATA[i*8 +: 8]); // XOR all bits in each byte
    end
    return parity;
  endfunction

  // Function to calculate expected parity for read data
  function bit [3:0] calc_rdata_parity(bit [31:0] PRDATA);
    bit [3:0] parity;
    for (int i = 0; i < 4; i++) begin
      parity[i] = ~(^PRDATA[i*8 +: 8]); // XOR all bits in each byte
    end
    return parity;
  endfunction
/*
  // Function to check if address parity is correct
  function bit check_addr_parity();
    bit [3:0] expected_parity = calc_addr_parity();
    return (PADDRCHK == expected_parity);
  endfunction

  // Function to check if write data parity is correct
  function bit check_wdata_parity();
    bit [3:0] expected_parity = calc_wdata_parity();
    return (PWDATACHK == expected_parity);
  endfunction

  // Function to check if read data parity is correct
  function bit check_rdata_parity();
    bit [3:0] expected_parity = calc_rdata_parity();
    return (PRDATACHK == expected_parity);
  endfunction
*/
  // Function to calculate expected parity for strobe signals
  function bit calc_strb_parity(bit [3:0]PSTRB);
    bit parity;
    	parity = ~(^PSTRB[3:0]);  // Single parity bit for entire PSTRB (matches RTL: pstrb_parity_bit = ^PSTRB)
    return parity;
  endfunction
/*
  // Function to check if strobe parity is correct
  function bit check_strb_parity();
    bit [3:0] expected_parity = calc_strb_parity();
    return (PSTRBCHK == expected_parity);
  endfunction
*/
  function new(string name = "apb_transaction");
    super.new(name);
  endfunction
// coverage disable
  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(PRESETn, UVM_ALL_ON)
    `uvm_field_int(PADDR, UVM_ALL_ON)
    `uvm_field_int(PWRITE, UVM_ALL_ON)
    `uvm_field_int(PWDATA, UVM_ALL_ON)
    `uvm_field_int(PSTRB, UVM_ALL_ON)
    `uvm_field_int(PRDATA, UVM_ALL_ON)
    `uvm_field_int(PADDRCHK, UVM_ALL_ON)
    `uvm_field_int(PWDATACHK, UVM_ALL_ON)
    `uvm_field_int(PSTRBCHK, UVM_ALL_ON)
    `uvm_field_int(PRDATACHK, UVM_ALL_ON)
    `uvm_field_int(PREADY, UVM_ALL_ON)
    `uvm_field_int(PSLVERR, UVM_ALL_ON)
//    `uvm_field_int(wait_cycles, UVM_ALL_ON)
  `uvm_object_utils_end
// coverage enable
endclass
