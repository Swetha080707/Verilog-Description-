
module baud_gen(input wire clk,
                input wire resetn,
                input wire [15:0] divisor,
                output reg baud_tick);
                reg [15:0] counter;
                always @(posedge clk or negedge resetn)begin
                    if (!resetn) begin
                        counter <= 16'd0;
                        baud_tick <= 1'b0;
                end
                else begin
                if(counter == divisor-1)begin
                   counter <= 16'd0;
                   baud_tick <= 1'b1;
                end
                else begin
                   counter <= counter + 1'b1;
                   baud_tick <= 1'b0;
                end
             end
          end 
endmodule