`timescale 1ns / 1ps

module islemci_tb;
    reg clk = 1, valid_in;
    wire valid_out;
    integer i;
    reg flag = 1'b1;   
    islemci uut (clk, valid_in, valid_out);
    reg[15:0] aa;
    always begin
       clk = ~clk;
       #10;
    end
    
    initial begin
       valid_in = 1'b1;
       $readmemb("Mem.mem", uut.m0.Mem);
       wait(valid_out == 1);
       aa = uut.Regs[4];
       if (uut.Regs[6] == 16'h004c) $display("SUCCESS !!");
       else $display("Better luck next run ..!");
       valid_in = 0;
       
    end
endmodule
