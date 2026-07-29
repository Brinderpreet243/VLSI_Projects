`timescale 1ns / 1ps

// Self-checking testbench for Dual-Port Synchronous RAM
// Covers: basic write/read, both ports, collision, boundary addresses, data retention
module tb_dual_port_ram;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg clk, rst;
    reg we_a, we_b;
    reg [ADDR_WIDTH-1:0] addr_a, addr_b;
    reg [DATA_WIDTH-1:0] din_a, din_b;
    wire [DATA_WIDTH-1:0] dout_a, dout_b;

    int errors = 0;

    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Task: write through Port A, read it back next cycle, and check
    task test_port_a(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] val);
        @(posedge clk);
        we_a = 1; addr_a = addr; din_a = val;
        @(posedge clk);
        we_a = 0;
        addr_a = addr;          // keep addr stable for read
        @(posedge clk);         // wait for read to latch
        if (dout_a !== val) begin
            errors++;
            $display("[FAIL] Port A: addr=%0d expected=0x%0h got=0x%0h", addr, val, dout_a);
        end else
            $display("[PASS] Port A: addr=%0d = 0x%0h", addr, dout_a);
    endtask

    // Task: write through Port B, read it back next cycle, and check
    task test_port_b(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] val);
        @(posedge clk);
        we_b = 1; addr_b = addr; din_b = val;
        @(posedge clk);
        we_b = 0;
        addr_b = addr;
        @(posedge clk);
        if (dout_b !== val) begin
            errors++;
            $display("[FAIL] Port B: addr=%0d expected=0x%0h got=0x%0h", addr, val, dout_b);
        end else
            $display("[PASS] Port B: addr=%0d = 0x%0h", addr, dout_b);
    endtask

    initial begin
        $dumpfile("tb_dual_port_ram.vcd");
        $dumpvars(0, tb_dual_port_ram);

        clk = 0; rst = 1;
        we_a = 0; we_b = 0;
        addr_a = 0; addr_b = 0;
        din_a = 0; din_b = 0;

        @(posedge clk); rst = 0;
        @(posedge clk);

        // ---- Test 1: Port A basic write/read ----
        $display("\n--- Test 1: Port A basic write/read ---");
        test_port_a(4'd2, 8'hAA);

        // ---- Test 2: Port B basic write/read ----
        $display("\n--- Test 2: Port B basic write/read ---");
        test_port_b(4'd5, 8'h55);

        // ---- Test 3: Shared memory — Port A reads what Port B wrote ----
        $display("\n--- Test 3: Shared memory read ---");
        @(posedge clk);
        addr_a = 4'd5;   // Port B wrote 0x55 here
        @(posedge clk);
        if (dout_a !== 8'h55) begin
            errors++;
            $display("[FAIL] Shared memory: Port A read 0x%0h from addr 5, expected 0x55", dout_a);
        end else
            $display("[PASS] Shared memory: addr=5 = 0x%0h (written by Port B)", dout_a);

        // ---- Test 4: Both ports write DIFFERENT addresses same cycle ----
        $display("\n--- Test 4: Simultaneous write to DIFFERENT addresses ---");
        @(posedge clk);
        we_a = 1; addr_a = 4'd3; din_a = 8'h11;
        we_b = 1; addr_b = 4'd7; din_b = 8'h22;
        @(posedge clk);
        we_a = 0; we_b = 0;
        addr_a = 4'd3; addr_b = 4'd7;
        @(posedge clk);
        if (dout_a !== 8'h11) begin errors++; $display("[FAIL] Port A @ addr 3"); end
        else $display("[PASS] Port A: addr=3 = 0x%0h", dout_a);
        if (dout_b !== 8'h22) begin errors++; $display("[FAIL] Port B @ addr 7"); end
        else $display("[PASS] Port B: addr=7 = 0x%0h", dout_b);

        // ---- Test 5: COLLISION — both write SAME address (Port A should win) ----
        $display("\n--- Test 5: COLLISION — same address, both ports (Port A wins) ---");
        @(posedge clk);
        we_a = 1; addr_a = 4'd0; din_a = 8'hA5;
        we_b = 1; addr_b = 4'd0; din_b = 8'h5A;
        @(posedge clk);
        we_a = 0; we_b = 0;
        addr_a = 4'd0; addr_b = 4'd0;
        @(posedge clk);
        if (dout_a !== 8'hA5) begin errors++; $display("[FAIL] Collision: Port A"); end
        else $display("[PASS] Collision: addr=0 = 0x%0h (Port A wrote 0xA5)", dout_a);
        if (dout_b !== 8'hA5) begin errors++; $display("[FAIL] Collision: Port B"); end
        else $display("[PASS] Collision: Port B sees 0x%0h (Port B's write was blocked)", dout_b);

        // ---- Test 6: Boundary addresses ----
        $display("\n--- Test 6: Boundary addresses (0 and max) ---");
        test_port_a(4'd0,  8'hFF);
        test_port_b(4'd15, 8'h01);

        // ---- Test 7: Data retention ----
        $display("\n--- Test 7: Data retention (old values still there) ---");
        @(posedge clk);
        addr_a = 4'd2; addr_b = 4'd5;
        @(posedge clk);
        if (dout_a !== 8'hAA) begin errors++; $display("[FAIL] Retention: addr=2"); end
        else $display("[PASS] Retention: addr=2 = 0x%0h", dout_a);
        if (dout_b !== 8'h55) begin errors++; $display("[FAIL] Retention: addr=5"); end
        else $display("[PASS] Retention: addr=5 = 0x%0h", dout_b);

        // ---- Summary ----
        $display("\n========================================");
        if (errors == 0)
            $display("  ALL TESTS PASSED (0 errors)");
        else
            $display("  %0d TEST(S) FAILED", errors);
        $display("========================================");
        $finish;
    end

endmodule
