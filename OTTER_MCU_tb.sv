`timescale 1ns / 1ps

module OTTER_MCU_tb();
    // Testbench signals
    logic clk = 0;
    logic rst = 0;
    logic intr = 0;
    logic [31:0] iobus_in;
    logic [31:0] iobus_out;
    logic [31:0] iobus_addr;
    logic iobus_wr;

    // Memory array to hold instructions and data
    logic [31:0] memory [4095:0];  // 4K memory

    // Clock generation (100MHz)
    always begin
        #5 clk = ~clk;
    end

    // DUT instantiation
    OTTER_MCU DUT(
        .CLK(clk),
        .RST(rst),
        .INTR(intr),
        .IOBUS_IN(iobus_in),
        .IOBUS_OUT(iobus_out),
        .IOBUS_ADDR(iobus_addr),
        .IOBUS_WR(iobus_wr)
    );

    // Initialize memory with program
    initial begin
        // Clear memory
        for(int i = 0; i < 4096; i++) begin
            memory[i] = 32'h0;
        end

        // Load program
        memory[0] = 32'hAA055297;  // lui x5, 0xAA055
        memory[1] = 32'h76528413;  // addi x8, x5, 0x765
        memory[2] = 32'h00341513;  // slli x10, x8, 3
        memory[3] = 32'h0082A613;  // slt x12, x5, x8
        memory[4] = 32'h00A44693;  // xor x13, x8, x10
        memory[5] = 32'hFE000AE3;  // beq x0, x0, main
    end

    // Memory read simulation
    always_comb begin
        if(iobus_addr < 4096)
            iobus_in = memory[iobus_addr[31:2]];  // Word-aligned access
        else
            iobus_in = 32'h0;
    end

    // Memory write simulation
    always_ff @(posedge clk) begin
        if(iobus_wr && iobus_addr < 4096)
            memory[iobus_addr[31:2]] <= iobus_out;
    end

    // Test stimulus and expected results
    initial begin
        // Wait 100 ns for global reset
        #100;
        
        // Apply reset
        rst = 1;
        #20;
        rst = 0;
        
        // Expected values after each instruction
        // lui x5, 0xAA055    -> x5  = 0xAA055000
        // addi x8, x5, 0x765 -> x8  = 0xAA055765
        // slli x10, x8, 3    -> x10 = 0x502AB2B8
        // slt x12, x5, x8    -> x12 = 1
        // xor x13, x8, x10   -> x13 = 0xFA2FE5DD
        
        // Run for enough cycles to see results
        #1000;
        
        $stop;  // Use $stop for Vivado instead of $finish
    end

    // Monitor block for Vivado
    always @(posedge clk) begin
        $timeformat(-9, 2, " ns", 20);
        if (!rst) begin
            $display("Time=%t PC=%h", $time, DUT.pc_out);
            $display("    x5=%h", DUT.registers.ram[5]);
            $display("    x8=%h", DUT.registers.ram[8]);
            $display("   x10=%h", DUT.registers.ram[10]);
            $display("   x12=%h", DUT.registers.ram[12]);
            $display("   x13=%h", DUT.registers.ram[13]);
            $display("   ALU=%h", DUT.alu_result);
            $display("  State=%h\n", DUT.control_fsm.current_state);
        end
    end

endmodule 
