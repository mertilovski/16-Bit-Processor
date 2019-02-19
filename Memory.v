`timescale 1ns / 1ps

module Memory(
    input [15:0] PC,
    output [15:0] instruction,
    input [15:0] address1, address2, dest_address,
    output [15:0] data1, data2,
    input [15:0]dest_data,
    input write
    );
    
    reg [7:0] Mem [65635:0]; // Birle?ik bellek

    assign instruction = {Mem[PC+16'h0001],Mem[PC]};
    assign data1 = {Mem[address1+16'h1], Mem[address1]};
    assign data2 = {Mem[address2+16'h1], Mem[address2]};
    
    always @* begin
        if (write)begin 
            Mem[dest_address] = dest_data[7:0]; 
            Mem[dest_address+16'h1] = dest_data[15:8]; 
        end
    end
    
endmodule
