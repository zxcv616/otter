module OTTER_MCU(
    input logic CLK,
    input logic RST,
    input logic INTR,
    // Memory interface
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

    // Internal signals
    logic [31:0] pc_out;           // Current PC value
    logic [31:0] pc_next;          // Next PC value
    logic [31:0] instruction;      // Current instruction
    logic [31:0] mem_data;         // Data from memory
    
    // Register file signals
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] reg_wr_data;
    
    // ALU signals
    logic [31:0] alu_result;
    logic [3:0] alu_fun;
    logic [31:0] alu_srcA, alu_srcB;
    
    // Control signals from decoder
    logic [3:0] alu_fun_decoded;
    logic [1:0] alu_srcA_sel;
    logic [2:0] alu_srcB_sel;
    logic [3:0] pc_source;
    logic [1:0] rf_wr_sel;
    
    // Control signals from FSM
    logic pc_write;
    logic reg_write;
    logic mem_we2;
    logic mem_rden1;
    logic mem_rden2;
    logic reset;
    
    // Immediate values
    logic [31:0] u_imm, i_imm, s_imm, b_imm, j_imm;
    
    // Branch condition signals
    logic br_eq, br_ltu, br_lt;
    
    // Branch/Jump target addresses
    logic [31:0] branch_addr, jal_addr, jalr_addr;

    // Program Counter
    PC program_counter(
        .PC_WRITE(pc_write),
        .PC_RST(reset),
        .PC_DIN(pc_next),
        .CLK(CLK),
        .PC_COUNT(pc_out)
    );

    // PC Multiplexer
    PC_MUX pc_mux(
        .pc(pc_out),
        .jalr(jalr_addr),
        .branch(branch_addr),
        .jal(jal_addr),
        .mtvec(32'b0),  // Not implementing trap handling
        .mepc(32'b0),   // Not implementing trap handling
        .sel(pc_source[2:0]),  // Using only lower 3 bits
        .out(pc_next)
    );

    // Register File
    reg_file registers(
        .adr1(instruction[19:15]),
        .adr2(instruction[24:20]),
        .wa(instruction[11:7]),
        .wd(reg_wr_data),
        .en(reg_write),
        .clk(CLK),
        .rs1(rs1_data),
        .rs2(rs2_data)
    );

    // ALU
    ALU alu(
        .A(alu_srcA),
        .B(alu_srcB),
        .ALU_FUN(alu_fun),
        .RESULT(alu_result)
    );

    // Immediate Generator
    imm_gen immediate_gen(
        .instr(instruction[31:7]),
        .u_type(u_imm),
        .i_type(i_imm),
        .s_type(s_imm),
        .b_type(b_imm),
        .j_type(j_imm)
    );

    // Branch Address Generator
    bag branch_addr_gen(
        .PC(pc_out),
        .rs1(rs1_data),
        .j_type(j_imm),
        .b_type(b_imm),
        .i_type(i_imm),
        .jal(jal_addr),
        .jalr(jalr_addr),
        .branch(branch_addr)
    );

    // Branch Condition Generator
    bcg branch_cond_gen(
        .value1(rs1_data),
        .value2(rs2_data),
        .br_eq(br_eq),
        .br_ltu(br_ltu),
        .br_lts(br_lt)  // Note: This connects to br_lt in decoder
    );

    // Control Unit - FSM
    CU_FSM control_fsm(
        .clk(CLK),
        .RST(RST),
        .INTR(INTR),
        .ir(instruction[6:0]),
        .PCWrite(pc_write),
        .regWrite(reg_write),
        .memWE2(mem_we2),
        .memRDEN1(mem_rden1),
        .memRDEN2(mem_rden2),
        .reset(reset)
    );

    // Control Unit - Decoder
    CU_DCDR control_decoder(
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .IR30(instruction[30]),
        .br_eq(br_eq),
        .br_ltu(br_ltu),
        .br_lt(br_lt),
        .ALU_FUN(alu_fun_decoded),
        .ALU_srcA(alu_srcA_sel),
        .ALU_srcB(alu_srcB_sel),
        .pcSource(pc_source),
        .rf_wr_sel(rf_wr_sel)
    );

    // ALU source A multiplexer
    always_comb begin
        case(alu_srcA_sel)
            2'b00: alu_srcA = rs1_data;
            2'b01: alu_srcA = pc_out;
            default: alu_srcA = 32'b0;
        endcase
    end

    // ALU source B multiplexer
    always_comb begin
        case(alu_srcB_sel)
            3'b000: alu_srcB = rs2_data;
            3'b001: alu_srcB = i_imm;
            3'b010: alu_srcB = s_imm;
            3'b011: alu_srcB = u_imm;
            default: alu_srcB = 32'b0;
        endcase
    end

    // Register write data multiplexer
    always_comb begin
        case(rf_wr_sel)
            2'b00: reg_wr_data = 32'b0;
            2'b01: reg_wr_data = pc_out + 4;
            2'b10: reg_wr_data = mem_data;
            2'b11: reg_wr_data = alu_result;
        endcase
    end

    // Memory interface assignments
    assign IOBUS_OUT = rs2_data;
    assign IOBUS_ADDR = alu_result;
    assign IOBUS_WR = mem_we2;
    
    // Instruction and data memory read assignments
    always_comb begin
        if (mem_rden1) 
            instruction = IOBUS_IN;
        if (mem_rden2)
            mem_data = IOBUS_IN;
    end

    // Connect decoded ALU function to ALU
    assign alu_fun = alu_fun_decoded;

endmodule 