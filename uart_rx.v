module uart_rx (
    input  wire       clk,
    input  wire       resetn,
    input  wire       baud_tick,
    input  wire       rx_in,
    input  wire       parity_type,
    input  wire       parity_enable,

    output reg  [7:0] rx_data,
    output reg        rx_done,
    output reg        parity_error,
    output reg        frame_error
);
    localparam IDLE   = 3'b000,
               START  = 3'b001,
               DATA   = 3'b010,
               PARITY = 3'b011,
               STOP   = 3'b100;
    reg [2:0] state;
    reg [3:0] tick_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift_reg;
    reg rx_sync1;
    reg rx_sync2;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end

        else begin
            rx_sync1 <= rx_in;
            rx_sync2 <= rx_sync1;
        end

    end
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state        <= IDLE;
            tick_count   <= 4'd0;
            bit_index    <= 3'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;
            rx_done      <= 1'b0;
            parity_error <= 1'b0;
            frame_error  <= 1'b0;
        end
        else begin
            rx_done <= 1'b0;
            if (baud_tick) begin
                case (state)
                    IDLE: begin
                        tick_count <= 4'd0;
                        bit_index  <= 3'd0;
                        if (rx_sync2 == 1'b0) begin
                            state        <= START;
                            parity_error <= 1'b0;
                            frame_error  <= 1'b0;
                        end
                    end
                    START: begin
                        if (tick_count == 4'd7) begin
                            if (rx_sync2 == 1'b0) begin
                                tick_count <= 4'd0;
                                bit_index  <= 3'd0;
                                state      <= DATA;
                            end
                            else begin
                                state <= IDLE;
                            end
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    DATA: begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            rx_shift_reg[bit_index] <= rx_sync2;
                            if (bit_index == 3'd7) begin
                                if (parity_enable)
                                    state <= PARITY;
                                else
                                    state <= STOP;
                            end
                            else begin
                                bit_index <= bit_index + 1'b1;
                            end
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    PARITY: begin
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            if (parity_type == 1'b0)
                                parity_error <=
                                    (rx_sync2 != (^rx_shift_reg));
                            else
                                parity_error <=
                                    (rx_sync2 != ~(^rx_shift_reg));

                            state <= STOP;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    STOP: begin

                        if (tick_count == 4'd15) begin

                            tick_count <= 4'd0;
                            state      <= IDLE;

                            rx_data <= rx_shift_reg;
                            rx_done <= 1'b1;

                            if (rx_sync2 == 1'b0)
                                frame_error <= 1'b1;
                            else
                                frame_error <= 1'b0;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    default: begin
                        state      <= IDLE;
                        tick_count <= 4'd0;
                        bit_index  <= 3'd0;
                    end
                endcase
            end
        end
    end
endmodule