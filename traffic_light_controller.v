module traffic_light_controller(
input clk,
input reset,
output reg  red,
output reg  green,
output reg  yellow);
parameter RED = 2'b00;
parameter GREEN = 2'b01;
parameter YELLOW = 2'b10;
reg [1:0] current_state;
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
   current_state <= RED;
  end
  else
  begin
     case (current_state)
        RED:
        begin
           current_state <= GREEN;
        end   
        GREEN:
        begin
           current_state <= YELLOW;
        end
        YELLOW:
        begin
           current_state <= RED;
        end
        default:
        begin
          current_state <= RED;
        end
        endcase
    end
end
always @(*)
begin
  red = 0;
  green = 0;
  yellow = 0;
  case (current_state)
  RED:
  begin
     red = 1;
     green = 0;
     yellow = 0;
  end
  GREEN:
  begin
     red = 0;
     green = 1;
     yellow = 0; 
  end
  YELLOW:
  begin
     red = 0;
     green = 0;
     yellow = 1;
  end 
  default:
  begin
     red = 1;
     green = 0;
     yellow = 0;
  end
  endcase
  end
endmodule