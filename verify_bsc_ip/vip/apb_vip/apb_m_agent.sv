class apb_m_agent extends uvm_agent;
    `uvm_component_utils(apb_m_agent)

    virtual apb_if apb_vif;

    // Components
    apb_m_sequencer apb_seq;
    apb_m_driver apb_dri;
    apb_m_monitor apb_mon;

    // Constructor
    function new(string name = "apb_m_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "[Build phase] Entered...", UVM_MEDIUM);
        
        //get config db
        if(!uvm_config_db #(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
           `uvm_fatal(get_type_name(),"[apb_if] Cant get interface, pls check!");
        end

        //create dri, seq, mon
        apb_dri = apb_m_driver::type_id::create("apb_dri", this);
        apb_seq = apb_m_sequencer::type_id::create("apb_seq", this);
        apb_mon = apb_m_monitor::type_id::create("apb_mon", this);

        //set config db
        uvm_config_db #(virtual apb_if)::set(this, "apb_mon", "apb_vif", apb_vif);
        uvm_config_db #(virtual apb_if)::set(this, "apb_dri", "apb_vif", apb_vif);

        `uvm_info(get_type_name(), "[Build phase] Exiting...", UVM_MEDIUM);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        apb_dri.seq_item_port.connect(apb_seq.seq_item_export);
        `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM);
    endfunction

endclass
