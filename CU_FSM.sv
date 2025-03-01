module CU_FSM (
    input logic clk,
    input logic RST,
    input logic INTR,
    input logic [6:0] ir,
    output logic PCWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset
);

    typedef enum logic [1:0] {
        INIT  = 2'b00,
        FETCH = 2'b01,
        EXEC  = 2'b10
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk) begin
        if (RST)
            current_state <= INIT;
        else
            current_state <= next_state;
    end

    always_comb begin
        // Default values to prevent latches
        PCWrite   = 1'b0;
        regWrite  = 1'b0;
        memWE2    = 1'b0;
        memRDEN1  = 1'b0;
        memRDEN2  = 1'b0;
        reset     = 1'b0;
        next_state = current_state;

        case (current_state)
            INIT: begin
                reset = 1'b1;
                next_state = FETCH;
            end

            FETCH: begin
                memRDEN1 = 1'b1;
                next_state = EXEC;
            end

            EXEC: begin
                next_state = FETCH;  // Default next state
                
                case (ir)
                    7'b0110011: begin  // R-type
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b0010011: begin  // I-type
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b0000011: begin  // Load
                        memRDEN2 = 1'b1;
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b0100011: begin  // Store
                        memWE2 = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b1100011: begin  // Branch
                        PCWrite = 1'b1;
                    end
                    
                    7'b0110111: begin  // LUI
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b0010111: begin  // AUIPC
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    7'b1101111,        // JAL
                    7'b1100111: begin  // JALR
                        regWrite = 1'b1;
                        PCWrite = 1'b1;
                    end
                    
                    default: begin
                        PCWrite = 1'b1;
                    end
                endcase
            end

            default: begin
                next_state = INIT;
            end
        endcase

        if (INTR && current_state != INIT) begin
            next_state = FETCH;
        end
    end

endmodule
