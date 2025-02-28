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
        7'b0110011: // R-TYPE Instructions
            begin
                rf_wr_sel = 2'b11;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b000;
                pcSource = 4'b0000;

                case (funct3)
                    3'b000: ALU_FUN = IR30 ? 4'b1000 : 4'b0000;
                    3'b111: ALU_FUN = 4'b0111;
                    3'b110: ALU_FUN = 4'b0110;
                    3'b001: ALU_FUN = 4'b0001;
                    3'b011: ALU_FUN = 4'b0011;
                    3'b101: ALU_FUN = IR30 ? 4'b1101 : 4'b0101;
                    3'b100: ALU_FUN = 4'b0100;
                    default: ;
                endcase
            end

        7'b0010011: // I-TYPE Instructions
            begin
                rf_wr_sel = 2'b11;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b001;

                case (funct3)
                    3'b000: ALU_FUN = 4'b0000;
                    3'b111: ALU_FUN = 4'b0111;
                    3'b110: ALU_FUN = 4'b0110;
                    3'b001: ALU_FUN = 4'b0001;
                    3'b010: ALU_FUN = 4'b0010;
                    3'b011: ALU_FUN = 4'b0011;
                    3'b101: ALU_FUN = IR30 ? 4'b1101 : 4'b0101;
                    3'b100: ALU_FUN = 4'b0100;
                    default: ;
                endcase
            end

        7'b0100011: // S-TYPE Instructions
            begin
                ALU_FUN = 4'b0000;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b010;
                rf_wr_sel = 2'b00;
                pcSource = 4'b0000;
            end

        7'b1100011: // B-TYPE
            begin
                ALU_FUN = 4'b0000;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b000;
                rf_wr_sel = 2'b00;

                case (funct3)
                    3'b000: if (br_eq) pcSource = 4'b0010;
                    3'b101: if (br_eq | !br_lt) pcSource = 4'b0010;
                    3'b111: if (br_eq | !br_ltu) pcSource = 4'b0010;
                    3'b100: if (br_lt) pcSource = 4'b0010;
                    3'b110: if (br_ltu) pcSource = 4'b0010;
                    3'b001: if (!br_eq) pcSource = 4'b0010;
                    default: ;
                endcase
            end

        7'b0000011: // LOAD Instructions
            begin
                ALU_FUN = 4'b0000;    // Add for address calculation
                ALU_srcA = 2'b00;     // rs1
                ALU_srcB = 3'b001;    // Immediate
                rf_wr_sel = 2'b10;    // Write data from memory
                pcSource = 4'b0000;   // Next sequential PC
                
                case (funct3)
                    3'b000: ; // LB 
                    3'b001: ; // LH 
                    3'b010: ; // LW  
                    3'b100: ; // LBU 
                    3'b101: ; // LHU 
                    default: ;
                endcase
            end

        7'b0110111: // LUI
            begin
                ALU_FUN = 4'b1001;
                ALU_srcA = 2'b01;
                ALU_srcB = 3'b000;
                rf_wr_sel = 2'b11;
            end

        7'b0010111: // AUIPC
            begin
                ALU_FUN = 4'b0000;
                ALU_srcA = 2'b01;
                ALU_srcB = 3'b011;
                rf_wr_sel = 2'b11;
                pcSource = 4'b0000;
            end

        7'b1101111: // JAL
            begin
                ALU_FUN = 4'b0000;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b000;
                rf_wr_sel = 2'b01;
                pcSource = 4'b0011;
            end

        7'b1100111: // JALR
            begin
                ALU_FUN = 4'b0000;
                ALU_srcA = 2'b00;
                ALU_srcB = 3'b000;
                rf_wr_sel = 2'b01;
                pcSource = 4'b0001;
            end

        default: ;
    endcase
end

endmodule