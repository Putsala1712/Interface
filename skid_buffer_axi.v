`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2025 08:32:06
// Design Name: 
// Module Name: skid_buffer_axi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module skid_buffer_axi #(parameter WIDTH=32)
 ( // Global signals
    input  aclk,aresetn,
    //input interface
    input i_valid,
    input [WIDTH-1:0] i_data,
    output reg i_ready,
    //output interface
    output reg o_valid,
    output reg [WIDTH-1:0] o_data,
    input o_ready);
  
  //skid_buffer internal signals
    reg [WIDTH-1:0] s_data =0;
    reg s_valid =0;
  //assign i_ready = (~s_valid) & ~(s_valid & o_ready) ; // data transfers when o_ready=1 or when o_ready=0 & buffer is empty(s_valid=0)
  
  always @(posedge aclk or negedge aresetn)
    begin
    i_ready = (~s_valid) & ~(s_valid & o_ready) ;
      if(~aresetn)
        begin
          o_data <= 0;
          o_valid <= 0;
        end
        
    /*  else begin
        if(i_valid && i_ready) 
        begin
            if(o_ready)  
            begin
                o_data <= i_data; // direct data transfer
                o_valid <= 1;
            end
            else 
            begin
                s_data <= i_data; // data transfers into skid buffer
                s_valid <=1;
            end
        end
        
        if(s_valid && o_ready)
        begin
          o_data <= s_data;       // data transfers from skid buffer to output
          o_valid <= 1;
          s_valid <= 0;
        end
        end */
        else begin
            // Default: no new output unless conditions met
            o_valid <= 0;

            // Case 1: Skid buffer flush has priority
            if (s_valid && o_ready) begin
                o_data  <= s_data;   // send old skid data out
                o_valid <= 1;
                s_valid <= 0;
                i_ready <= 0;

                /*if (i_valid) begin
                    // refill skid with new incoming data
                    s_data  <= i_data;
                    s_valid <= 1;
                end 
                else begin
                    // skid empty
                    s_valid <= 0;
                end*/
            end

            // Case 2: Direct transfer (skid empty, input valid, output ready)
            else if (i_valid && o_ready && ~s_valid) begin
                o_data  <= i_data;
                o_valid <= 1;
            end

            // Case 3: input valid, Output not ready - capture into skid
            else if (i_valid && ~o_ready && ~s_valid) begin
                s_data  <= i_data;
                s_valid <= 1;
            end
        end
   end
endmodule
