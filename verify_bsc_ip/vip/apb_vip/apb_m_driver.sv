class apb_m_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_m_driver)

    virtual apb_if vif;

    // Constructor
    function new(string name = "apb_m_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "[Build phase], Entered...", UVM_MEDIUM);
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "apb_vif", vif)) begin
       `uvm_fatal(get_type_name(), "[Build phase]Can't get interface, pls check!");
        end
        `uvm_info(get_type_name(), "[Build phase], Exiting...", UVM_MEDIUM);
    endfunction

    extern task drive_logic(apb_transaction tr);
    // Run phase
    apb_transaction tr;
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "[Run phase], entered...", UVM_MEDIUM);
        forever begin 
            $display("Waiting for transaction...");
            tr = apb_transaction::type_id::create("tr",this);
            
            seq_item_port.get_next_item(tr);
            `uvm_info(get_type_name(), $sformatf("========1========="), UVM_MEDIUM);
            `uvm_info(get_type_name(), $sformatf("[driver] Get trans in driver successfully \n%s", tr.sprint()), UVM_MEDIUM);
            drive_logic(tr);
            seq_item_port.item_done();
            `uvm_info(get_type_name(), $sformatf("[driver] Send driver to dut"), UVM_MEDIUM);
        end
        `uvm_info(get_type_name(), "[Run phase], exiting...", UVM_MEDIUM);
    endtask
endclass

task apb_m_driver::drive_logic(apb_transaction tr);
    `uvm_info(get_type_name(), $sformatf("tr.PRESETn=%b \n trans: tr=\n%s ", tr.PRESETn, tr.sprint()), UVM_MEDIUM);
    if(!tr.PRESETn) begin
        // Reset transaction
        $display("Starting reset transaction...");
        vif.PRESETn = 1'b0;
        @(posedge vif.PCLK); // Wait one clock cycle
        vif.PADDR <= 32'h0000_0000;
        vif.PWRITE <= 1'b0;
        vif.PWDATA <= 32'h0000_0000;
        vif.PSTRB <= 4'b0000;  // Reset strobe
        vif.PSEL <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PADDRCHK <= 4'b0;
        vif.PWDATACHK <= 4'b0;
        vif.PSTRBCHK <= 1'b0;  // Reset strobe parity check
        $display("Driving reset transaction - PRESETn = 0");
        repeat(2) @(posedge vif.PCLK);
        // vif.PRESETn = 1'b1; // Release reset
        $display("Reset released - PRESETn = 1");
        `uvm_info(get_type_name(), "Reset transaction driven", UVM_MEDIUM);
    end else begin
        // For now, just acknowledge non-reset transactions
        // $display("Non-reset transaction received - doing nothing for now");
        `uvm_info(get_type_name(), $sformatf("========2========="), UVM_MEDIUM);
        vif.PRESETn = 1'b1; // Ensure reset is deasserted
        vif.PENABLE = 1'b0;
        vif.PADDR <= tr.PADDR;
        vif.PWRITE <= tr.PWRITE;
        if(tr.PWRITE==1'b1) begin
            vif.PWDATA <= tr.PWDATA;
            vif.PSTRB <= tr.PSTRB;  // Drive byte enable strobe
        end
        vif.PSEL <= 1'b1; // Select the slave
        vif.PADDRCHK <= tr.PADDRCHK;
        vif.PWDATACHK <= tr.PWDATACHK;
        vif.PSTRBCHK <= tr.PSTRBCHK;  // Drive strobe parity check

        @(posedge vif.PCLK); // Wait one clock cycle
        vif.PENABLE <= 1'b1; // Enable the transaction

        // Wait for slave to be ready using clocking block
        do begin
            @(posedge vif.PCLK);
            `uvm_info(get_type_name(), $sformatf("=====vif.pready=%h", vif.PREADY), UVM_MEDIUM);
        end while (!vif.PREADY);

        if (!tr.PWRITE) begin
            tr.PRDATA = vif.PRDATA; // Read data from slave
            tr.PRDATACHK = vif.PRDATACHK; // Read data parity check
            // `uvm_info(get_type_name(), $sformatf("Read data: %0h", tr.PRDATA), UVM_MEDIUM);
        end

        `uvm_info(get_type_name(), $sformatf("=====3======"), UVM_MEDIUM);
        
        vif.PADDR <= 32'h00;
        vif.PWRITE <= 1'b0;
        vif.PWDATA <= 32'h00;
        vif.PSTRB <= 4'b0;
        vif.PENABLE <= 1'b0; // Disable the transaction
        vif.PSEL <= 1'b0; // Deselect the slave
        @(posedge vif.PCLK); // Wait one clock cycle
    end
endtask
