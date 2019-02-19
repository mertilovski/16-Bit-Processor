`timescale 1ns / 1ps


module islemci(
    input clk, // saat sinyali
    input valid_in, // 1 olunca çal?? 0 olunca dur
    output valid_out // Buyruk belle?indeki program bitince 1 bitmezse 0
    );
    
    reg [15:0] Regs [15:0]; // Yazmaçlar
     
    reg [15:0]PC = 16'h0000, PC_next=16'h0000; // Özel yazmaçlar ve ilk değerleri
	reg [15:0]SFR_A = 16'h0000, SFR_A_next=16'h0000;
    
    reg valid_out_r = 1'b0, valid_out_r_next=1'b0; // Program bitişini kontrol eden yazmaç
 
    // Buyruklar
    localparam ILKER = 3'b000, TASI= 3'b001,GNC= 3'b010,KAP= 3'b011,KAC= 3'b100,TPL= 3'b101,DAL= 3'b110,KAY= 3'b111;
    
    //Çalışma ya da durma durumlar?
    localparam RUNNING = 1'b1, IDLE = 1'b0;
    
	
	//Kullanılacak değişkenlerin tanımı
   
    reg [15:0]tmpYa; 
    reg [15:0]tmpYb;    
    reg [15:0]tmpYc; 
    reg [15:0] Rx,Ry,Rz;
    reg[2:0] opcode;
	reg[15:0] Rx_data,Ry_data,Rz_data;
	reg[15:0] immediate9;
    reg[15:0] immediate13;
	
	// AMB
	reg op;
	reg[15:0] op1;
	reg[15:0] op2;
	wire[15:0] res;
	wire amb_isEqual;
	// Extender
	reg [12:0] immed;
	reg isNine,isSigned;
	wire [15:0] extended;
	// Memory
	wire[15:0] instruction;
    reg[15:0] addr1,addr2;
    reg[15:0] daddr;
    wire[15:0] data1,data2;
    reg[15:0] ddata;
    reg in;
    // Shifter
    reg shift_isEqual;
    wire[15:0] shifted;
    reg[15:0] shift_in;
    AMB a0(.op(op),
           .operand1(op1),
           .operand2(op2),
           .result(res),
           .isEqual(amb_isEqual));
	
    Extender e0(.immediate(immed),
                .isNine(isNine),
                .withSign(isSigned),
                .extended(extended));
                
    Memory m0(.PC(PC),
              .instruction(instruction),
              .address1(addr1), 
              .address2(addr2), 
              .dest_address(daddr),
              .data1(data1), 
              .data2(data2),
              .dest_data(ddata),
              .write(in));
   
    Shifter s0(.isEqual(shift_isEqual),
               .Rx(shift_in),
               .SFR_A(SFR_A),
               .shifted(shifted));
              
	
    reg state = IDLE, state_next = IDLE;
    
    
    always @* begin
        //Değişkenlerin varsayılan değerleri
		
		SFR_A_next = SFR_A;
        opcode = instruction[15:13];
        Rx= instruction[12:9];
        Ry= instruction[8:5];
        Rz= instruction[4:1];
        immediate9 = instruction[8:0];
        immediate13 = instruction[12:0];
		
        state_next = state;
        tmpYa = Regs[Rx];
        tmpYb = Regs[Ry];
        tmpYc = Regs[Rz];
		
        PC_next = PC;
		
        valid_out_r_next = 0;
		
        //Memory
        addr1 = 0;
        addr2 = 0;
        daddr = 0;
        in = 0;
        //AMB
		op1 = 0;
        op2 = 0;
        op = 0;
        //Extender
        immed = 0;
        isNine = 0;
        isSigned = 0;
        
        //Shifter
        shift_isEqual = 0;
        shift_in = 0;
        Rx_data = tmpYa;
        Ry_data = tmpYb;
        Rz_data = tmpYc;
     
        // Eğer program çalışıyorsa buyruk işleme
        if(state == RUNNING) begin
            //Program bitimi kontrolü
            
			if(PC == 16'hff ) begin
                valid_out_r_next = 1'b1 ;
                //state_next = IDLE;
			end
            //Program bitmediyse
            else begin
                PC_next = PC + 2;
                case(opcode)
                    
				    ILKER: begin
				        daddr = tmpYa;
				        addr1 = tmpYb;
				        addr2 = tmpYc;
                        op1 = data1;
                        op2 = data2;
                        op = 0;
				        ddata = res;
				        in = 1'b1;
				    end
				    TASI: begin  
		                isNine = 1;
		                isSigned = 1;
		                immed = immediate9;
                        tmpYa = extended;
                    end
      			    GNC: begin       
                        immed = immediate13;
                        SFR_A_next = extended;
                    end
					
					KAP:begin					
					   addr1 = SFR_A;
                       tmpYa = data1;
					end
					
	           		KAC:begin
					   in = 1;	           		
                       ddata = tmpYa;            
                       daddr = SFR_A;   
                    end
					TPL:begin
					   op1 = tmpYb;
					   op2 = tmpYc;
					   op = 0;
					   tmpYa = res;
					end
					DAL: begin
				        op1 = tmpYb;
                        op2 = tmpYc;
				        if(!amb_isEqual) begin
				            PC_next = PC + tmpYa;
				        end
					end
                    KAY: begin
                        op1 = tmpYb;
                        op2 = tmpYc;
                        shift_isEqual = amb_isEqual;
                        shift_in = Rx_data;
                        tmpYa = shifted;
                    end     
                endcase
            end
        end
		
        // Program çalışmıyorsa bekleme durumu
        else if (state == IDLE) begin
            PC_next = 16'h0000;
            if(valid_in) begin
                state_next = RUNNING;
            end
        end
    end
    
    //Çevrim sonunda yap?lacak atamalar
    always @(posedge clk) begin
        Regs[Rx] <= tmpYa;
        SFR_A <= SFR_A_next;
        PC <= PC_next;
        valid_out_r <= valid_out_r_next;
        state <= state_next;
    end
    
    //Programın bittiğini gösteren çıkışın atanması
    assign valid_out = valid_out_r;
endmodule
