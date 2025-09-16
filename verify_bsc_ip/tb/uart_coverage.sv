ahb_transaction    ahb_trans_cov   = ahb_transaction::type_id::create("ahb_trans_cov");
uart_transaction   uart_trans_cov  = uart_transaction::type_id::create("uart_trans_cov");
uart_configuration uart_config_cov = uart_configuration::type_id::create("uart_config_cov");

covergroup AHB;
	
	xact_type: coverpoint ahb_trans_cov.xact_type {
		bins READ  = {ahb_transaction::READ};
		bins WRITE = {ahb_transaction::WRITE};
	}

	addr: coverpoint ahb_trans_cov.addr {
		bins MDR = {'h00};
		bins DLL = {'h04};
		bins DLH = {'h08};
		bins LCR = {'h0C};
		bins IER = {'h10};
		bins FSR = {'h14};
		bins TBR = {'h18};
		bins RBR = {'h1C};
		bins rsvd = {['h020:'h3FF]};
	}	

	data: coverpoint ahb_trans_cov.data {
		bins data = {['h00:'hFF]};
	}

	LCR_frame_databit: coverpoint ahb_trans_cov.data[1:0] {
		bins data_width_5 = {2'b00};
		bins data_width_6 = {2'b01};
		bins data_width_7 = {2'b10};
		bins data_width_8 = {2'b11};
	}

	LCR_frame_stopbit: coverpoint ahb_trans_cov.data[2] {
		bins stop_width_1 = {1'b0};
		bins stop_width_2 = {1'b1};
	}

	LCR_enable_parity: coverpoint ahb_trans_cov.data[3] {
		bins en  = {1'b1};
		bins dis = {1'b0};
	}

	LCR_frame_parity: coverpoint ahb_trans_cov.data[4] {
		bins odd  = {1'b0};
		bins even = {1'b1};
	}

	MDR_sample_mode: coverpoint ahb_trans_cov.data[0] {
		bins x16 = {1'b0};
		bins x13 = {1'b1};
	}

	IER_interrupt: coverpoint ahb_trans_cov.data {
		bins en_parity_error  = {'hC};
		bins en_rx_fifo_empty = {'h8};
		bins en_rx_fifo_full  = {'h4};
		bins en_tx_fifo_empty = {'h2};
		bins en_tx_fifo_full  = {'h1};
	}

	DLL_mode_x13: coverpoint ahb_trans_cov.data {
		bins baud_2400   = {'h85};
		bins baud_4800   = {'h42};
		bins baud_9600   = {'h21};
		bins baud_19200  = {'h91};
		bins baud_38400  = {'hC8};
		bins baud_76800  = {'h64};
		bins baud_115200 = {'h43};
	}

	DLL_mode_x16: coverpoint ahb_trans_cov.data {
		bins baud_2400   = {'h2C};
		bins baud_4800   = {'h16};
		bins baud_9600   = {'h8B};
		bins baud_19200  = {'h45};
		bins baud_38400  = {'hA3};
		bins baud_76800  = {'h51};
		bins baud_115200 = {'h36};
	}

	DLH_mode_x13: coverpoint ahb_trans_cov.data {
		bins baud_2400   = {'hC};
		bins baud_4800   = {'h6};
		bins baud_9600   = {'h3};
		bins baud_19200  = {'h1};
		bins baud_38400  = {'h0};
		bins baud_76800  = {'h0};
		bins baud_115200 = {'h0};
	}

	DLH_mode_x16: coverpoint ahb_trans_cov.data {
		bins baud_2400   = {'hA};
		bins baud_4800   = {'h5};
		bins baud_9600   = {'h2};
		bins baud_19200  = {'h1};
		bins baud_38400  = {'h0};
		bins baud_76800  = {'h0};
		bins baud_115200 = {'h0};
	}

	reg_access: cross addr, xact_type {
		ignore_bins read_tbr  = binsof(xact_type.READ) && binsof(addr.TBR);
		ignore_bins write_rbr = binsof(xact_type.WRITE) && binsof(addr.RBR);
	}

	func_full_duplex: cross LCR_frame_databit, LCR_frame_stopbit, LCR_frame_parity {}

endgroup

covergroup UART;

	parity_mode: coverpoint uart_config_cov.parity_mode {
		bins NONE = {uart_configuration::PARITY_NONE};
		bins ODD  = {uart_configuration::PARITY_ODD};
		bins EVEN = {uart_configuration::PARITY_EVEN};
	}

	data_width: coverpoint uart_config_cov.data_width {
		bins bit_data_5 = {'d5};
		bins bit_data_6 = {'d6};
		bins bit_data_7 = {'d7};
		bins bit_data_8 = {'d8};
	}

	stop_bit: coverpoint uart_config_cov.stop_bits {
		bins stop_1 = {1};
		bins stop_2 = {2};
	}

	baud_rate: coverpoint uart_config_cov.baud_rate {
		bins common_baud_rate  = {2400, 4800, 9600, 19200, 38400, 76800, 115200};
		bins custom_baud_rate  = {130000, 160000};
	}

	data: coverpoint uart_trans_cov.data {
		bins data = {[0:255]};
	}

	direction: coverpoint uart_trans_cov.direction {
		bins transmit = {uart_transaction::DIR_TX};
		bins receive  = {uart_transaction::DIR_RX};
	}

	inject_parity_error: coverpoint uart_trans_cov.parity_error {
		bins parity_er = {1};
	}

	basic_function: cross parity_mode, baud_rate, data_width, stop_bit, direction {
		ignore_bins ignore_custom_baud = binsof(baud_rate.custom_baud_rate);
	}

	parity_error_function: cross parity_mode, baud_rate, stop_bit , inject_parity_error {
		bins parity_error_func = binsof(inject_parity_error.parity_er) && 
		                         binsof(parity_mode.EVEN) &&
		                         binsof(stop_bit.stop_2) &&
		                         binsof(baud_rate.common_baud_rate);
		ignore_bins ignore_parity_er   = !binsof(inject_parity_error.parity_er);
		ignore_bins ignore_parity_none = binsof(parity_mode.NONE);
		ignore_bins ignore_parity_odd  = binsof(parity_mode.ODD);
		ignore_bins ignore_stop_1      = binsof(stop_bit.stop_1);
		ignore_bins ignore_custom_baud = binsof(baud_rate.custom_baud_rate);
	}
		
endgroup
