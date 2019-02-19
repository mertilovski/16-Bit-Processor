`timescale 1ns / 1ps

module AMB(
    input op,
    input [15:0] operand1, operand2,
    output reg [15:0] result,
    output reg isEqual
    );
    
    always @* begin
    
        if(op == 1'b0) begin
            result = operand1 + operand2;    
        end
        if(op == 1'b1) begin 
            result = operand1-operand2;
        end 
        if(operand1 == operand2)
            isEqual = 1;
        else
            isEqual = 0;     
	end
	
endmodule
