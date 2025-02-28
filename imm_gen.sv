module imm_gen (
    input  logic [31:7] instr,  // Bits 31:7 of the instruction
    output logic [31:0] u_type,  // Output for U-Type
    output logic [31:0] i_type,  // Output for I-Type
    output logic [31:0] s_type,  // Output for S-Type
    output logic [31:0] b_type,  // Output for B-Type
    output logic [31:0] j_type   // Output for J-Type
);

    // Assign statements for each immediate type
    assign u_type = {instr[31:12], 12'b0};  // U-Type (Upper Immediate)
    assign i_type = {{21{instr[31]}}, instr[30:20]}; // I-Type (Sign-extended Immediate)
    assign s_type = {{21{instr[31]}}, instr[30:25], instr[11:7]}; // S-Type (Store Immediate)
    assign b_type = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-Type (Branch Immediate)
    assign j_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-Type (Jump Immediate)

endmodule
