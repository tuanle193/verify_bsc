class axi_transaction extends uvm_sequence_item;

    typedef enum {WRITE,READ} trans_type_enum;

    typedef enum {
        FIXED = 2'b00,
        INCR  = 2'b01,
        WRAP  = 2'b10
    } burst_type_enum;

    rand bit [31:0] addr ; // addr start 
    rand bit [7:0]  len  ; // 0 to 255 beats
    rand bit [1:0]  size ; // beat size: 1B, 2B, 4B, 8B
    rand trans_type_enum trans_type;
    rand burst_type_enum burst_type;

    rand bit [ID_WIDTH-1:0] id; // ID transaction 

    rand bit [DATA_WIDTH/8-1:0] wstrb[];
    rand bit [DATA_WIDTH-1:0]   rdata[];
    rand bit [DATA_WIDTH-1:0]   wdata[];

    rand bit [1:0] rresp[]; // read response per beat
    rand bit [1:0] bresp  ; // write response

    //---------------------------------
    // Constraints
    // --------------------------------
    constraint c_burst {
        burst_type == FIXED; // FIXED only
    }

    constraint c_len {
        len <= 255;
    }

    constraint c_data_size {
        if(trans_type == WRITE) {
            wdata.size() == len + 1;
            wstrb.size() == len + 1;
        }
        if(trans_type == READ) {
            rdata.size() == len + 1;
            rresp.size() == len + 1;
        }
    }

    //--------------------------------
    // UVM field macro
    //--------------------------------
    `uvm_object_utils_begin(axi_transaction)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(len , UVM_DEFAULT)
        `uvm_field_int(size, UVM_DEFAULT)
        `uvm_field
    `uvm_object_utils_end

    //--------------------------------
    // function new
    //--------------------------------
    function new(string name = "axi_transaction"
        super.new(name);
    endfunction

    //--------------------------------
    // get next addr
    //--------------------------------
    function bit [31:0] get_next_addr(bit [31:0] current_addr, int beat);
        if(burst == 3'b000) begin // FIXED
            return current_addr;
        end else if(burst == 3'b000) begin // INCR
            `UVM_FATAL(get_type_name,"Unsupport INCR burst");
        end else if(burst == 3'b001) begin
            `UVM_FATAL(get_type_name,"Unsupport WRAP burst");
        end
    endfunction

endclass

