class uart_reg_block extends uvm_reg_block;
	`uvm_object_utils(uart_reg_block)

	rand uart_MDR_reg MDR;
	rand uart_DLL_reg DLL;
	rand uart_DLH_reg DLH;
	rand uart_LCR_reg LCR;
	rand uart_IER_reg IER;
	rand uart_FSR_reg FSR;
	rand uart_TBR_reg TBR;
	rand uart_RBR_reg RBR;
	rand uart_reserved_reg reserved_reg[];

	uvm_reg_map ahb_map;

	//-------------------------
	// Constructor
	//-------------------------
	function new(string name = "uart_reg_block");
		super.new(name);
	endfunction

	//---------------------------
	// Function: build
	//---------------------------
	virtual function void build();
		MDR = uart_MDR_reg::type_id::create("MDR");
		DLL = uart_DLL_reg::type_id::create("DLL");
		DLH = uart_DLH_reg::type_id::create("DLH");
		LCR = uart_LCR_reg::type_id::create("LCR");
		IER = uart_IER_reg::type_id::create("IER");
		FSR = uart_FSR_reg::type_id::create("FSR");
		TBR = uart_TBR_reg::type_id::create("TBR");
		RBR = uart_RBR_reg::type_id::create("RBR");

		MDR.configure(this);
		DLL.configure(this);
		DLH.configure(this);
		LCR.configure(this);
		IER.configure(this);
		FSR.configure(this);
		TBR.configure(this);
		RBR.configure(this);

		MDR.build();
		DLL.build();
		DLH.build();
		LCR.build();
		IER.build();
		FSR.build();
		TBR.build();
		RBR.build();

		reserved_reg = new[248];
		for(int i = 0; i < 248; i++) begin
			reserved_reg[i] = uart_reserved_reg::type_id::create($sformatf("reserved_reg_%0d",i));
			reserved_reg[i].configure(this);
			reserved_reg[i].build();
		end

		ahb_map = create_map("ahb_map",'h0,4,UVM_LITTLE_ENDIAN);
		ahb_map.add_reg(MDR, `UVM_REG_ADDR_WIDTH'h000, "RW");
		ahb_map.add_reg(DLL, `UVM_REG_ADDR_WIDTH'h004, "RW");
		ahb_map.add_reg(DLH, `UVM_REG_ADDR_WIDTH'h008, "RW");
		ahb_map.add_reg(LCR, `UVM_REG_ADDR_WIDTH'h00C, "RW");
		ahb_map.add_reg(IER, `UVM_REG_ADDR_WIDTH'h010, "RW");
		ahb_map.add_reg(FSR, `UVM_REG_ADDR_WIDTH'h014, "RW");
		ahb_map.add_reg(TBR, `UVM_REG_ADDR_WIDTH'h018, "WO");
		ahb_map.add_reg(RBR, `UVM_REG_ADDR_WIDTH'h01C, "RO");

		for(int i = 0; i < 248; i++) begin
			uvm_reg_addr_t addr = 'h20 + (i * 'h4);
			ahb_map.add_reg(reserved_reg[i], addr, "RO");
		end

		lock_model();
	endfunction

endclass



