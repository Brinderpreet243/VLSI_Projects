`timescale 1ns / 1ps

module full_adder_opt (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    wire p, g;

    // Propagate and Generate logic (Half-Adder 1)
    assign p = a ^ b;
    assign g = a & b;

    // Output logic (Half-Adder 2)
    assign sum  = p ^ cin;
    assign cout = g | (p & cin);

endmodule
