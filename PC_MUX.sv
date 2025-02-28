module PC_MUX (
    input logic [31:0] pc, // Input for PC
    input logic [31:0] jalr, // Input for JALR
    input logic [31:0] branch, // Input for branch
    input logic [31:0] jal, // Input for JAL
    input logic [31:0] mtvec, // Input for mtvec
    input logic [31:0] mepc, // Input for mepc
    input logic [2:0] sel, // Selection input for mux
    
    output logic [31:0] out // MUX output
);

always_comb begin
    case (sel)
        3'b000: out = pc + 4; // Select PC + 4
        3'b001: out = jalr; // Select JALR
        3'b010: out = branch; // Select branch
        3'b011: out = jal; // Select JAL
        3'b100: out = mtvec; // Select mtvec
        3'b101: out = mepc; // Select mepc
        default: out = 32'b0; // Default zero
    endcase
end

endmodule
