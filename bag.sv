module bag(
		input logic [31:0] PC, // Program counter
		input logic [31:0] rs1, // Register source
		input logic [31:0] j_type, // imm jal value
		input logic [31:0] b_type, // imm branch value
		input logic [31:0] i_type, // imm jalr value
		output logic [31:0] jal, // jal output
		output logic [31:0] jalr, // jalr output
		output logic [31:0] branch // branch output
);

always_comb begin
		branch = PC + b_type;
		jal = PC + j_type;
		jalr = rs1 + i_type;

		end
endmodule