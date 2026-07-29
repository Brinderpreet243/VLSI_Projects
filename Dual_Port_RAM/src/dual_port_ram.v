`timescale 1ns / 1ps

// Dual-Port Synchronous RAM
// Both ports can read/write independently on every clock cycle.
// When both ports write to the same address simultaneously, Port A wins.
module dual_port_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire we_a,
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire [DATA_WIDTH-1:0] din_a,
    output reg [DATA_WIDTH-1:0] dout_a,
    input wire we_b,
    input wire [ADDR_WIDTH-1:0] addr_b,
    input wire [DATA_WIDTH-1:0] din_b,
    output reg [DATA_WIDTH-1:0] dout_b
);

    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];
    integer i;

    // Initialize all locations to zero on reset
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            ram[i] = {DATA_WIDTH{1'b0}};
    end

    // Port A
    always @(posedge clk) begin
        if (rst) begin
            dout_a <= {DATA_WIDTH{1'b0}};
        end else begin
            if (we_a) ram[addr_a] <= din_a;
            dout_a <= ram[addr_a];
        end
    end

    // Port B (Port A has priority on simultaneous write collision)
    always @(posedge clk) begin
        if (rst) begin
            dout_b <= {DATA_WIDTH{1'b0}};
        end else begin
            if (we_b && !(we_a && addr_a == addr_b))
                ram[addr_b] <= din_b;
            dout_b <= ram[addr_b];
        end
    end

endmodule