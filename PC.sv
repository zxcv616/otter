module PC (
		input logic PC_WRITE, // Enables writing to PC
		input logic PC_RST, // Active high sync reset
		input logic [31:0] PC_DIN, // Input value for loading
		input logic CLK, // Clock
		output logic [31:0] PC_COUNT // Count output
);

always_ff @(posedge CLK) begin
		if (PC_RST) begin
				PC_COUNT <= 32'b0; // Reset PC to zero
		end else if (PC_WRITE) begin
				PC_COUNT <= PC_DIN; // Load the value into the PC
		end
end

endmodule