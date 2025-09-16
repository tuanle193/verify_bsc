`uvm_analysis_imp_decl(_uart)
`uvm_analysis_imp_decl(_ahb)
class uart_scoreboard extends uvm_scoreboard;	
	`uvm_component_utils(uart_scoreboard)
	`include"uart_coverage.sv";
	
	uart_configuration uart_config;

	uvm_analysis_imp_uart #(uart_transaction, uart_scoreboard) uart_export;
	uvm_analysis_imp_ahb  #(ahb_transaction, uart_scoreboard)  ahb_export;

	byte tbr_data[$];
	byte rbr_data[$];
	byte uart_txd[$];
	byte uart_rxd[$];

	//------------------------------------
	// Constructor
	//------------------------------------
	function new(string name = "uart_scoreboard",uvm_component parent);
		super.new(name, parent);
		AHB  = new();
		UART = new();
	endfunction

	//-----------------------------------
	// build phase
	//-----------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uart_export = new("uart_export",this);
		ahb_export  = new("ahb_export",this);
		if(!uvm_config_db#(uart_configuration)::get(this,"","uart_config",uart_config))
			`uvm_fatal(get_type_name(),"Failed to get config from uvm config db")
	endfunction

	//-----------------------------------
	// Function: write_ahb
	//-----------------------------------
	function void write_ahb(ahb_transaction ahb_trans);
		if(ahb_trans.xact_type == ahb_transaction::WRITE && ahb_trans.addr == 'h018) begin
			tbr_data.push_back(ahb_trans.data[7:0]);
			`uvm_info(get_type_name(),$sformatf("WRITE TO TRB: data=0x%0h",ahb_trans.data[7:0]),UVM_LOW)
		end
		$cast(ahb_trans_cov,ahb_trans);
		AHB.sample();
	endfunction

	//-----------------------------------
	// Function: write_uart
	//-----------------------------------
	function void write_uart(uart_transaction uart_trans);
		if(uart_trans.direction == uart_transaction::DIR_RX) begin
			uart_txd.push_back(uart_trans.data);
			`uvm_info(get_type_name(),$sformatf("DUT transmit data=0x%0h",uart_trans.data),UVM_LOW)
		end
		if(uart_trans.direction == uart_transaction::DIR_TX) begin
			uart_rxd.push_back(uart_trans.data);
			`uvm_info(get_type_name(),$sformatf("DUT receive data=0x%0h",uart_trans.data),UVM_LOW)
		end
		uart_config = uart_trans.current_config;
		$cast(uart_trans_cov,uart_trans);
		$cast(uart_config_cov,uart_config);
		UART.sample();
	endfunction

	//-----------------------------------
	// Task: run_phase
	//-----------------------------------
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			wait(tbr_data.size() > 0 && uart_txd.size() > 0 || rbr_data.size() > 0 && uart_rxd.size() > 0);
			if(tbr_data.size() > 0 && uart_txd.size() > 0)
				compare_transmit_data();
			if(rbr_data.size() > 0 && uart_rxd.size() > 0)
				compare_receive_data();
		end
	endtask

	//----------------------------------
	// Function: compare transmit data
	//----------------------------------
	function void compare_transmit_data();
		byte exp_data = tbr_data.pop_front();
		byte act_data = uart_txd.pop_front();
		if(exp_data != act_data)
			`uvm_error(get_type_name(),$sformatf("Transmit data missmatch: expect=0x%0h actual=0x%0x",exp_data,act_data))
		else
			`uvm_info(get_type_name(),$sformatf("Data match"),UVM_LOW)
	endfunction

	//----------------------------------
	// Function: compare receive data
	//----------------------------------
	function void compare_receive_data();
		byte exp_data = uart_rxd.pop_front();
		byte act_data = rbr_data.pop_front();
		if(exp_data != act_data)
			`uvm_error(get_type_name(),$sformatf("Receive data missmatch: expect=0x%0h actual=0x%0x",exp_data,act_data))
		else
			`uvm_info(get_type_name(),$sformatf("Data match"),UVM_LOW)
	endfunction

	//-------------------------------------
	// Function: update rbr data
	//------------------------------------
	function void update_rbr_data(input bit[7:0] rdata);
		rbr_data.push_back(rdata);
		`uvm_info(get_type_name(),$sformatf("READ from RBR: data=0x%0h",rdata),UVM_LOW)
	endfunction

	//-------------------------------------
	// Function: get tbr fifo
	//-------------------------------------
	function bit[7:0] get_tbr_fifo();
		return tbr_data[0];
	endfunction

	//---------------------------------------
	// Function: is tbr fifo empty
	//---------------------------------------
	function bit is_tbr_fifo_empty();
		return (tbr_data.size() == 0);
	endfunction
	
endclass
