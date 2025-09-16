class uart_reg2ahb_adapter extends uvm_reg_adapter;
	`uvm_object_utils(uart_reg2ahb_adapter)

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "uart_reg2ahb_adapter");
		super.new(name);
		supports_byte_enable = 0;
		provides_responses	 = 1;
	endfunction

	//-----------------------------------------
	// reg2bus
	//-----------------------------------------
	virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
		ahb_transaction ahb = ahb_transaction::type_id::create("ahb");
		ahb.xact_type  = (rw.kind == UVM_WRITE) ? ahb_transaction::WRITE : ahb_transaction::READ;
		ahb.addr			 = rw.addr;
		ahb.data			 = rw.data;
		ahb.xfer_size  = ahb_transaction::SIZE_32BIT;
		ahb.burst_type = ahb_transaction::SINGLE;
		ahb.prot			 = 0;
		ahb.lock			 = 0;
		`uvm_info(get_type_name(),$sformatf("reg2bus: addr=0x%0h data=0x%0h kind=%0s",ahb.addr,ahb.data,ahb.xact_type.name()),UVM_HIGH)
		return ahb;
	endfunction

	//--------------------------------------------
	// bus2reg
	//-------------------------------------------
	virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
		ahb_transaction ahb;
		if(!$cast(ahb,bus_item))
			`uvm_fatal(get_type_name(),"Failed to cast bus_item to ahb transaction")
	
		rw.kind = (ahb.xact_type == ahb_transaction::WRITE) ? UVM_WRITE : UVM_READ;
		rw.addr = ahb.addr;
		rw.data = ahb.data;
		`uvm_info(get_type_name(),$sformatf("bus2reg: addr=0x%0h data=0x%0h kind=%0s status=%0s",rw.addr,rw.data,rw.kind.name(),rw.status.name()),UVM_HIGH)
	endfunction

endclass
