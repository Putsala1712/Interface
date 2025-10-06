//Method-1: Testbench
`timescale 1ns / 1ps

module axi_fifo_tb();
parameter DATA_WIDTH = 32;
parameter FIFO_DEPTH = 16;

reg aclk;
reg aresetn;

// Slave interface
reg  [DATA_WIDTH-1:0] s_data;
reg s_valid;
wire s_ready;

// Master interface
wire [DATA_WIDTH-1:0] m_data;
wire m_valid;
reg  m_ready;
integer i,j,wi,ri;
// DUT instantiation
fifo_axi #(DATA_WIDTH,FIFO_DEPTH) dut (aclk,aresetn,s_data,s_valid,s_ready,m_data,m_valid,m_ready);

// Clock generation
initial aclk=0;
always #5 aclk = ~aclk;
    
initial begin
   
aresetn = 0;
s_valid = 0;
s_data  = 0;
m_ready = 0;

#20 aresetn = 1;
end

task write_fifo(input [DATA_WIDTH-1:0] din);
begin
@(posedge aclk);
s_valid=1;
s_data=din;
@(posedge aclk);
s_valid=0;
end
endtask

task read_axififo();
begin 
@(posedge aclk);
m_ready=1;
@(posedge aclk);
m_ready=0;
end
endtask

initial begin
@(posedge aresetn);
@(posedge aclk);
  
$display("Writing data into fifo");
for(i=0; i<FIFO_DEPTH; i=i+1)
begin
write_fifo($urandom);
$display(" %h data written in fifo",i); 
end

  
$display("Reading data from fifo");
for(j=0; j<FIFO_DEPTH; j=j+1)
begin
$display(" %h data read from fifo",j);
read_axififo();
end

$display("Simultaneous write and read operation to fifo");

fork 

begin
for(wi=0; wi<=30; wi=wi+1) begin
write_fifo($urandom);
end
end

begin
for(ri=0; ri<=31; ri=ri+1)begin
read_axififo();
end
end

join
    
#50;
$finish;
end  
endmodule
