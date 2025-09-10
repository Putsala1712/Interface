`timescale 1ns / 1ps

module skid_buffer_tb();
parameter WIDTH=32;
  reg aclk,aresetn;
  reg i_valid;
  reg [WIDTH-1:0] i_data;
  wire i_ready;
  wire o_valid;
  wire [WIDTH-1:0] o_data;
  reg o_ready;
  
 //dut
  skid_buffer_axi drt (aclk,aresetn,i_valid,i_data,i_ready,o_valid,o_data,o_ready);
  
  initial aclk=0;
  always #5 aclk=~aclk;
  
  initial begin
    aresetn =0;
    #20;
    aresetn=1; 
  end
  
  initial begin
    //initial values
    i_valid =0;
    i_data=0;
    o_ready=0;
    
    @(posedge aresetn);
    o_ready=1;
    
    //direct data transfer
    @(posedge aclk);
    i_data = 32'haadd_1234;
    i_valid=1;
    
    @(posedge aclk);
    i_valid=0;
    
    //Skid capture
    @(posedge aclk);
    i_data = 32'h3333_1234;
    i_valid=1;
    o_ready=0;
    
    // Flushing the skid  
    @(posedge aclk);
    o_ready=1;
    i_valid=0;
    
    //direct data transfer
    @(posedge aclk);
    i_valid=1;
    i_data = 32'h7777_cccc;
    @(posedge aclk);
    i_data  = 32'h0000_cccc;
    
    //Skid capture
    @(posedge aclk);
    i_data = 32'h1111_2222;
    o_ready =0;
    
    //Flushing the skid + new data capture in skid
    @(posedge aclk);
    o_ready=1;
    i_data = 32'h1236_9870;
    i_valid=1;
    
    @(posedge aclk);
    
    @(posedge aclk);
    i_valid=1;
    i_data = 32'hffff_ffff;
    
    @(posedge aclk);
    o_ready=0;
    i_data = 32'h0123_4567;
    
    @(posedge aclk);
    o_ready=1;
    
    repeat(2) @(posedge aclk);
    $finish;
  end
endmodule
