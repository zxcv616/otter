module CU_DCDR(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic IR30,
    input logic br_eq,
    input logic br_ltu,
    input logic br_lt,
    output logic [3:0] ALU_FUN,
    output logic [1:0] ALU_srcA,
    output logic [2:0] ALU_srcB,
    output logic [3:0] pcSource, 
    output logic [1:0] rf_wr_sel
);

always_comb begin
    // Initialize all outputs to zero
    ALU_FUN = 4'b0000;
    ALU_srcA = 2'b00;
    ALU_srcB = 3'b000;
    pcSource = 4'b0000;  
    rf_wr_sel = 2'b00;

    case (opcode)
        7'b0110011: begin // R-TYPE Instructions
            rf_wr_sel = 2'b11;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b000;
            pcSource = 4'b0000;
            case (funct3)
                3'b000: ALU_FUN = IR30 ? 4'b1000 : 4'b0000;  // ADD/SUB
                3'b111: ALU_FUN = 4'b0111;  // AND
                3'b110: ALU_FUN = 4'b0110;  // OR
                3'b001: ALU_FUN = 4'b0001;  // SLL
                3'b011: ALU_FUN = 4'b0011;  // SLTU
                3'b101: ALU_FUN = IR30 ? 4'b1101 : 4'b0101;  // SRA/SRL
                3'b100: ALU_FUN = 4'b0100;  // XOR
                default: ALU_FUN = 4'b0000;
            endcase
        end

        7'b0010011: begin // I-TYPE Instructions
            rf_wr_sel = 2'b11;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b001;
            pcSource = 4'b0000;
            case (funct3)
                3'b101: ALU_FUN = IR30 ? 4'b1101 : 4'b0101;  // SRAI/SRLI
                default: ALU_FUN = {1'b0, funct3};
            endcase
        end

        7'b0100011: begin // S-TYPE Instructions
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b010;
            rf_wr_sel = 2'b00;
            pcSource = 4'b0000;
        end

        7'b1100011: begin // B-TYPE Instructions
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b000;
            rf_wr_sel = 2'b00;
            pcSource = 4'b0000;  // Default to not taken

            case (funct3)
                3'b000: begin // BEQ
                    pcSource = br_eq ? 4'b0010 : 4'b0000;
                end
                3'b001: begin // BNE
                    pcSource = !br_eq ? 4'b0010 : 4'b0000;
                end
                3'b100: begin // BLT
                    pcSource = br_lt ? 4'b0010 : 4'b0000;
                end
                3'b101: begin // BGE
                    pcSource = (!br_lt || br_eq) ? 4'b0010 : 4'b0000;
                end
                3'b110: begin // BLTU
                    pcSource = br_ltu ? 4'b0010 : 4'b0000;
                end
                3'b111: begin // BGEU
                    pcSource = (!br_ltu || br_eq) ? 4'b0010 : 4'b0000;
                end
                default: pcSource = 4'b0000;
            endcase
        end

        7'b0000011: begin // LOAD Instructions
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b001;
            rf_wr_sel = 2'b10;
            pcSource = 4'b0000;
        end

        7'b0110111: begin // LUI
            ALU_FUN = 4'b1001;  // Pass through B
            ALU_srcA = 2'b01;
            ALU_srcB = 3'b000;
            rf_wr_sel = 2'b11;
            pcSource = 4'b0000;
        end

        7'b0010111: begin // AUIPC
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b01;
            ALU_srcB = 3'b011;
            rf_wr_sel = 2'b11;
            pcSource = 4'b0000;
        end

        7'b1101111: begin // JAL
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b000;
            rf_wr_sel = 2'b01;  // PC + 4
            pcSource = 4'b0011;
        end

        7'b1100111: begin // JALR
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b001;  // Use immediate
            rf_wr_sel = 2'b01;  // PC + 4
            pcSource = 4'b0001;
        end

        default: begin
            ALU_FUN = 4'b0000;
            ALU_srcA = 2'b00;
            ALU_srcB = 3'b000;
            pcSource = 4'b0000;
            rf_wr_sel = 2'b00;
        end
    endcase
end

endmodule
