class ASTCR extends uvm_reg;

	`uvm_object_utils(ASTCR);

	     uvm_reg_field RSVD;
	rand uvm_reg_field AST7;
	rand uvm_reg_field AST6;
	rand uvm_reg_field AST5;
	rand uvm_reg_field AST4;
	rand uvm_reg_field AST3;
	rand uvm_reg_field AST2;
	rand uvm_reg_field AST1;
	rand uvm_reg_field AST0;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "ASTCR");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD = uvm_reg_field::type_id::create("RSVD");
		AST7 = uvm_reg_field::type_id::create("AST7");
		AST6 = uvm_reg_field::type_id::create("AST6");
		AST5 = uvm_reg_field::type_id::create("AST5");
		AST4 = uvm_reg_field::type_id::create("AST4");
		AST3 = uvm_reg_field::type_id::create("AST3");
		AST2 = uvm_reg_field::type_id::create("AST2");
		AST1 = uvm_reg_field::type_id::create("AST1");
		AST0 = uvm_reg_field::type_id::create("AST0");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access	
		RSVD.configure(this,24,8,"RW",0,0,0,0,0);
		AST7.configure(this,1 ,7,"RW",0,1,1,1,0);
		AST6.configure(this,1 ,6,"RW",0,1,1,1,0);
		AST5.configure(this,1 ,5,"RW",0,1,1,1,0);
		AST4.configure(this,1 ,4,"RW",0,1,1,1,0);
		AST3.configure(this,1 ,3,"RW",0,1,1,1,0);
		AST2.configure(this,1 ,2,"RW",0,1,1,1,0);
		AST1.configure(this,1 ,1,"RW",0,1,1,1,0);
		AST0.configure(this,1 ,0,"RW",0,1,1,1,0);
	endfunction

endclass
