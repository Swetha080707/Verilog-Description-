`timescale 1ns / 1ps

module tb_uart_top;

    // Inputs
    reg        clk;
    reg        resetn;
    reg [15:0] divisor;
    reg        parity_type;
    reg        parity_enable;
    reg        tx_wr_en;
    reg [7:0]  tx_din;
    reg        rx_in;
    reg        rx_rd_en;

    // Outputs
    wire       tx_full;
    wire       tx_out;
    wire [7:0] rx_dout;
    wire       rx_empty;
    wire       parity_error;
    wire       frame_error;

    // Instantiate Top Module
    uart_top uut (
        .clk(clk),
        .resetn(resetn),
        .divisor(divisor),
        .parity_type(parity_type),
        .parity_enable(parity_enable),
        .tx_wr_en(tx_wr_en),
        .tx_din(tx_din),
        .tx_full(tx_full),
        .tx_out(tx_out),
        .rx_in(rx_in),
        .rx_rd_en(rx_rd_en),
        .rx_dout(rx_dout),
        .rx_empty(rx_empty),
        .parity_error(parity_error),
        .frame_error(frame_error)
    );

    // External Loopback Connection: Direct TX to RX
    always @(*) begin
        rx_in = tx_out;
    end

    // 100MHz System Clock Generation (10ns Period)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize Inputs
        clk           = 0;
        resetn        = 0;
        divisor       = 16'd1; // Divisor value for 115200 Baud at 100MHz
        parity_type   = 0;      // 0 = Even Parity
        parity_enable = 1;      // Enable Parity Checking
        tx_wr_en      = 0;
        tx_din        = 8'h00;
        rx_rd_en      = 0;

        // 2. Apply Reset
        #100;
        resetn = 1;
        #100;

        // 3. Transmit Data Byte (0x8A -> 10001010)
        $display("---------------------------------------");
        $display("[TB] Sending Data to TX FIFO: 0x8A");
        $display("---------------------------------------");
        tx_din   = 8'h8A;
        tx_wr_en = 1;
        #10;
        tx_wr_en = 0;

        // 4. Wait for Transmission and Reception to Finish (Around 200us)
        #200000;

        // 5. Read Received Data from RX FIFO
        rx_rd_en = 1;
        #10;
        rx_rd_en = 0;
        #100;

        // 6. Verification Display Log
        $display("---------------------------------------");
        $display("[TB] Received Data from RX FIFO: 0x%h", rx_dout);
        
        if (rx_dout == 8'h8A) begin
            $display("---------------------------------------");
            $display(" SUCCESS: Transmitted and Received Data Match!");
            $display("---------------------------------------");
        end else begin
            $display("---------------------------------------");
            $display(" ERROR: Data Mismatch or Received 0x00!");
            $display("---------------------------------------");
        end

        #1000;
        $finish;
    end

endmodule