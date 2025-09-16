class uart_environment extends uvm_env;
	`uvm_component_utils(uart_environment)

	virtual uart_if uart_vif;
	virtual ahb_if	ahb_vif;

	uart_agent uart_agt;
	ahb_agent	 ahb_agt;

	uart_configuration 	 uart_config;
	uart_scoreboard		 	 uart_sb;
	uart_reg_block		 	 regmodel;
	uart_reg2ahb_adapter ahb_adapter;

	uvm_reg_predictor #(ahb_transaction) ahb_predictor;

	//-----------------------------------
	// Constructor
	//----------------------------------
	function new(string name = "uart_environment", uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------
	// build phase
	//-----------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// get virtual interface
		if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(),"Failed to get uart interface")
		if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
			`uvm_fatal(get_type_name(),"Failed to get ahb interface")
		// get uart config
		if(!uvm_config_db #(uart_configuration)::get(this,"","uart_config",uart_config))
			`uvm_fatal(get_type_name(),"Failed to get uart config")
		
		uart_agt 			= uart_agent::type_id::create("uart_agt",this);
		ahb_agt 			= ahb_agent::type_id::create("ahb_agt",this);
		ahb_adapter 	= uart_reg2ahb_adapter::type_id::create("ahb_adapter");
		ahb_predictor = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor",this);
		uart_sb 			= uart_scoreboard::type_id::create("uart_sb",this);
		regmodel 		  = uart_reg_block::type_id::create("regmodel",this);
		regmodel.build();

		// set virtual interface
		uvm_config_db #(virtual uart_if)::set(this,"uart_agt","uart_vif",uart_vif);
		uvm_config_db #(virtual ahb_if)::set(this,"ahb_agt","ahb_vif",ahb_vif);
		// set uart config
		uvm_config_db #(uart_configuration)::set(this,"uart_agt","uart_config",uart_config);
		uvm_config_db #(uart_configuration)::set(this,"uart_sb","uart_config",uart_config);
	endfunction
	
	//------------------------------------
	// connect phase
	//------------------------------------
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(regmodel.get_parent() == null)
			regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);
		
		// predictor connect
		ahb_predictor.map = regmodel.ahb_map;
		ahb_predictor.adapter = ahb_adapter;
		ahb_agt.monitor.item_observed_port.connect(ahb_predictor.bus_in);

		// connect monitor to scoreboard
		ahb_agt.monitor.item_observed_port.connect(uart_sb.ahb_export);
		uart_agt.uart_mon.item_observed_port.connect(uart_sb.uart_export);
	endfunction

endclass
