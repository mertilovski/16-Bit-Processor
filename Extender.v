`timescale 1ns / 1ps

module Extender(
    input [12:0] immediate,
    input isNine,
    input withSign,
    output [15:0] extended
    );
    reg sign;
    reg [15:0] extended_r;
    assign extended = (withSign) ? extended_r : immediate;
    
    always @* begin
        sign = 1'b0;
        extended_r = 16'd0;
        if (isNine) begin
            sign = immediate[8];
            extended_r = (sign) ? {{7{1'b1}}, immediate[8:0]} : {{7{1'b0}}, immediate[8:0]};
        end
        else begin
            sign = immediate[12];
            extended_r = (sign) ? {{3{1'b1}},immediate} : immediate;
        end
    end
endmodule
