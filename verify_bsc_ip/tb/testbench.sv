module testbench;
	import uvm_pkg::*;
	import test_pkg::*;

	uart_if uart_vif();
	ahb_if  ahb_vif();

	uart_top u_dut(
									.HCLK(ahb_vif.HCLK),
									.HRESETN(ahb_vif.HRESETn),
									.HADDR(ahb_vif.HADDR),
									.HBURST(ahb_vif.HBURST),
									.HTRANS(ahb_vif.HTRANS),
									.HSIZE(ahb_vif.HSIZE),
									.HPROT(ahb_vif.HPROT),
									.HWRITE(ahb_vif.HWRITE),
									.HWDATA(ahb_vif.HWDATA),
									.HSEL(ahb_vif.HSEL),
									.HREADYOUT(ahb_vif.HREADYOUT),
									.HRDATA(ahb_vif.HRDATA),
									.HRESP(ahb_vif.HRESP),
									.uart_rxd(uart_vif.tx),
									.uart_txd(uart_vif.rx),
									.interrupt(uart_vif.interrupt)
								);

	assign ahb_vif.HSEL = 1'b1;

	// active reset
	initial begin
		ahb_vif.HRESETn = 0;
		#100ns ahb_vif.HRESETn = 1;
	end

	// init clock 100MHz
	initial begin
		ahb_vif.HCLK = 0;
		forever begin
			#5ns;
			ahb_vif.HCLK = ~ahb_vif.HCLK;
		end
	end

	initial begin
		uvm_config_db #(virtual ahb_if)::set(uvm_root::get(),"uvm_test_top","ahb_vif",ahb_vif);
		uvm_config_db #(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","uart_vif",uart_vif);

		run_test();
	end

endmodule
