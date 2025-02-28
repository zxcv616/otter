module reg_file(
    input logic [4:0] adr1,    // Address 1 for reading
    input logic [4:0] adr2,    // Address 2 for reading
    input logic [4:0] wa,      // Address for writing
    input logic [31:0] wd,     // Data to write
    input logic en,            // Write enable
    input logic clk,              // Clock signal
    output logic [31:0] rs1,   // Output from read address 1
    output logic [31:0] rs2    // Output from read address 2
);

    // 32x32 Register File Array
    logic [31:0] ram [31:0];

    // Initialize the memory to all zero (method 1)
    initial begin
        int i;
        for (i=0; i<32; i=i+1) begin
               ram[i] = 0;
        end
    end
    
    // Reading Logic with Default Values
    always_comb begin
        if (adr1 < 32) rs1 = ram[adr1];
        if (adr2 < 32) rs2 = ram[adr2];
    end
    
    always_ff @ (posedge clk) begin
				    if (en && wa != 0) begin
							   //write to register
							   
								 ram[wa] <= wd;
						end
	  end
endmodule
