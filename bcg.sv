module bcg (
    input  logic [31:0] value1, value2,   // 32-bit input operands
    output logic br_eq, br_ltu, br_lts   // Comparison results
);

    assign br_eq  = (value1 == value2);  // Equality comparison
    assign br_ltu = (value1 < value2);   // Unsigned less-than
    assign br_lts = ($signed(value1) < $signed(value2));  // Signed less-than

endmodule