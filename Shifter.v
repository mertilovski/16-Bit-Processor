`timescale 1ns / 1ps

module Shifter(
    input isEqual,
    input [15:0] Rx, SFR_A,
    output [15:0] shifted
    );
    
	reg[15:0] _s;
    always @* begin
    
        if(isEqual == 1'b1) begin
        
            _s = Rx << SFR_A;
        
        end
        else begin
        
            _s = Rx >> SFR_A;
        
        end
        
        
   end
   assign shifted = _s;
endmodule
