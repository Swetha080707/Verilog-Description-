module uart_top (
    input  wire        clk,
    input  wire        resetn,
    input  wire [15:0] divisor,
    input  wire        parity_type,
    input  wire        parity_enable,
    input  wire        tx_wr_en,
    input  wire [7:0]  tx_din,
    output wire        tx_full,
    output wire        tx_out,
    input  wire        rx_in,
    input  wire        rx_rd_en,
    output wire [7:0]  rx_dout,
    output wire        rx_empty,
    output wire        parity_error,
    output wire        frame_error
);
    wire baud_tick;
    wire [7:0] tx_fifo_dout;
    wire       tx_fifo_empty;
    wire       tx_fifo_rd_en;
    wire       tx_busy;
    wire       tx_done;

    // TX control
    reg        tx_start;
    reg        tx_data_valid;
    wire [7:0] rx_data;
    wire       rx_done;

    baud_gen baud_gen_inst (
        .clk       (clk),
        .resetn    (resetn),
        .divisor   (divisor),
        .baud_tick (baud_tick)
    );
    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) tx_fifo_inst (
        .clk   (clk),
        .resetn(resetn),

        .wr_en (tx_wr_en),
        .rd_en (tx_fifo_rd_en),
        .din   (tx_din),
        .dout  (tx_fifo_dout),

        .full  (tx_full),
        .empty (tx_fifo_empty)
    );

    assign tx_fifo_rd_en =
        (!tx_busy) &&
        (!tx_fifo_empty) &&
        (!tx_data_valid);

    always @(posedge clk or negedge resetn) begin

        if (!resetn) begin

            tx_data_valid <= 1'b0;
            tx_start      <= 1'b0;

        end

        else begin

            tx_start <= 1'b0;

            if (tx_fifo_rd_en) begin

                tx_data_valid <= 1'b1;

            end

            if (tx_data_valid && !tx_busy) begin

                tx_start      <= 1'b1;
                tx_data_valid <= 1'b0;
            end
        end
    end
    uart_tx uart_tx_inst (
        .clk          (clk),
        .resetn       (resetn),
        .baud_tick    (baud_tick),

        .tx_start     (tx_start),
        .tx_data      (tx_fifo_dout),

        .parity_type  (parity_type),
        .parity_enable(parity_enable),

        .tx_out       (tx_out),
        .tx_busy      (tx_busy),
        .tx_done      (tx_done)
    );
    uart_rx uart_rx_inst (
        .clk          (clk),
        .resetn       (resetn),
        .baud_tick    (baud_tick),
        .rx_in        (rx_in),

        .parity_type  (parity_type),
        .parity_enable(parity_enable),

        .rx_data      (rx_data),
        .rx_done      (rx_done),

        .parity_error (parity_error),
        .frame_error  (frame_error)
    );
    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) rx_fifo_inst (
        .clk   (clk),
        .resetn(resetn),

        .wr_en (rx_done),
        .rd_en (rx_rd_en),
        .din   (rx_data),
        .dout  (rx_dout),

        .full  (),
        .empty (rx_empty)
    );

endmodule