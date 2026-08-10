module uart_tx (
    input  wire       clk,
    input  wire       resetn,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       parity_type,
    input  wire       parity_enable,
    output reg        tx_out,
    output reg        tx_busy,
    output reg        tx_done
);
    localparam IDLE   = 3'b000,
               START  = 3'b001,
               DATA   = 3'b010,
               PARITY = 3'b011,
               STOP   = 3'b100;
    reg [2:0] state;
    reg [3:0] tick_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;
    reg       parity_bit;
    always @(*) begin
        if (parity_type == 1'b0)
            parity_bit = ^data_reg;
        else
            parity_bit = ~(^data_reg);
    end
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state      <= IDLE;
            tick_count <= 4'd0;
            bit_index  <= 3'd0;
            data_reg   <= 8'd0;
            tx_out     <= 1'b1;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;
        end
        else begin
            tx_done <= 1'b0;
            if (baud_tick) begin
                case (state)
                    IDLE: begin
                        tx_out  <= 1'b1;
                        tx_busy <= 1'b0;
                        if (tx_start) begin
                           data_reg   <= tx_data;
                            tick_count <= 4'd0;
                            bit_index  <= 3'd0;
                            tx_busy <= 1'b1;
                            state   <= START;
                        end
                    end
                    START: begin
                        tx_out <= 1'b0;
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            bit_index  <= 3'd0;
                            state      <= DATA;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    DATA: begin
                        tx_out <= data_reg[bit_index];
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
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
                        tx_out <= parity_bit;
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            state      <= STOP;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    STOP: begin
                        tx_out <= 1'b1;
                        if (tick_count == 4'd15) begin
                            tick_count <= 4'd0;
                            state   <= IDLE;
                            tx_busy <= 1'b0;
                            tx_done <= 1'b1;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                    default: begin
                        state      <= IDLE;
                        tick_count <= 4'd0;
                        bit_index  <= 3'd0;
                        tx_out  <= 1'b1;
                        tx_busy <= 1'b0;
                    end
                endcase
            end
        end
    end
endmodule