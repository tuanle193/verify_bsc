class error_catcher extends uvm_report_catcher;
	`uvm_object_utils(error_catcher)
	
	string error_msg_q[$];

	function new(string name= "timer_error_catcher");
		super.new(name);
	endfunction

	virtual function action_e catch();
		string str_cmp;
		string current_msg;

		if(get_severity() == UVM_ERROR) begin
			current_msg = get_message();

			foreach(error_msg_q[i]) begin
				str_cmp = error_msg_q[i];
				if(current_msg == str_cmp) begin
					set_severity(UVM_INFO);
					`uvm_info(get_type_name(),$sformatf("Demoted below error message: %s", str_cmp), UVM_NONE)
				end
				// check for pattern matching
				// transmit data missmatch
				if(str_cmp == "Transmit data missmatch: " && current_msg.substr(0,24) == str_cmp) begin
					set_severity(UVM_INFO);
					`uvm_info(get_type_name(),$sformatf("Demoted below error message: %s", current_msg), UVM_NONE)
				end
				// receive data missmatch
				if(str_cmp == "Receive data missmatch: " && current_msg.substr(0,23) == str_cmp) begin
					set_severity(UVM_INFO);
					`uvm_info(get_type_name(),$sformatf("Demoted below error message: %s", current_msg), UVM_NONE)
				end
			end
		end
		return THROW;

	endfunction

	virtual function void add_error_catcher_msg(string str);
		error_msg_q.push_back(str);
	endfunction

endclass

