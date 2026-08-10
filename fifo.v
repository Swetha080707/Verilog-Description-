module fifo #(
    parameter DATA_WIDTH = 8,       
    parameter DEPTH      = 16       
)(
    input  wire                  clk,
    input  wire                  resetn,

    input  wire                  wr_en,   
    input  wire                  rd_en,   
    input  wire [DATA_WIDTH-1:0] din,     

    output reg  [DATA_WIDTH-1:0] dout,    
    output wire                  full,    
    output wire                  empty    
);
    localparam ADDR_WIDTH = $clog2(DEPTH);    
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];   
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            dout <= 0;
        end
        else begin
            if (wr_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end
    assign empty = (wr_ptr == rd_ptr);
    assign full = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) &&
        (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);

endmodule