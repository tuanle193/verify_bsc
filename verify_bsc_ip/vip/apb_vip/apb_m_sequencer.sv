class apb_m_sequencer extends uvm_sequencer #(apb_transaction);
    `uvm_component_utils(apb_m_sequencer)

    // Constructor
    function new(string name = "apb_m_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
