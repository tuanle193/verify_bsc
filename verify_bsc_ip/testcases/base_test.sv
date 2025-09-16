class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)

	uvm_report_server svr;
	uart_environment  env;
	
	virtual ahb_if  ahb_vif;
	virtual uart_if uart_vif;

	uart_reg_block     regmodel;
	uart_configuration uart_config;

	error_catcher      err_catcher;

	time usr_timeout = 2s;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_base_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	//------------------------------------
	// build phase
	//------------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env         = uart_environment::type_id::create("env",this);
		uart_config = uart_configuration::type_id::create("uart_config");

		// get virtual interface
		if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
			`uvm_fatal(get_type_name(),"Failed to get ahb if from config db")
		if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(),"Failed to get uart if from config db")

		// default config
		uart_config.baud_rate   = 9600;
		uart_config.data_width  = 8;
		uart_config.parity_mode = uart_configuration::PARITY_NONE;
		uart_config.stop_bits   = 1;
		uart_config.active      = 1;

		// report catcher
		err_catcher = error_catcher::type_id::create("err_catcher");
		uvm_report_cb::add(null,err_catcher);

		// set virtual interface
		uvm_config_db #(virtual uart_if)::set(this,"env","uart_vif",uart_vif);
		uvm_config_db #(virtual ahb_if) ::set(this,"env","ahb_vif",ahb_vif);
		// set uart config
		uvm_config_db #(uart_configuration)::set(this,"env","uart_config",uart_config);

		uvm_top.set_timeout(usr_timeout);
	endfunction

	//--------------------------------
	// connect phase
	//--------------------------------
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.regmodel = env.regmodel;
	endfunction

	//---------------------------------------
	// end of elaboration phase
	//--------------------------------------
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	//-------------------------------------
	// final phase
	//-------------------------------------
	virtual function void final_phase(uvm_phase phase);
		super.final_phase(phase);
		`uvm_info(get_type_name(),"Entered...",UVM_LOW)
		svr = uvm_report_server::get_server();
		if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)) begin
			`uvm_info(get_type_name(),"-----------------------------------",UVM_NONE)
			`uvm_info(get_type_name(),"------------ TEST FAILED ----------",UVM_NONE)
			`uvm_info(get_type_name(),"-----------------------------------",UVM_NONE)
		end
		else begin
			`uvm_info(get_type_name(),"-----------------------------------",UVM_NONE)
			`uvm_info(get_type_name(),"------------ TEST PASSED ----------",UVM_NONE)
			`uvm_info(get_type_name(),"-----------------------------------",UVM_NONE)
		end
		`uvm_info(get_type_name(),"Exiting...",UVM_LOW)
	endfunction

endclass

