// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

/**
  always_comb begin
    LED <= SWI | clk_2;
    SEG <= SWI;
    lcd_WriteData <= SWI;
    lcd_pc <= 'h12;
    lcd_instruction <= 'h34567890;
    lcd_SrcA <= 'hab;
    lcd_SrcB <= 'hcd;
    lcd_ALUResult <= 'hef;
    lcd_Result <= 'h11;
    lcd_ReadData <= 'h33;
    lcd_MemWrite <= SWI[0];
    lcd_Branch <= SWI[1];
    lcd_MemtoReg <= SWI[2];
    lcd_RegWrite <= SWI[3];
    for(int i=0; i<NREGS_TOP; i++) lcd_registrador[i] <= i+i*16;
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end

**/

// Comece o codigo aqui 


logic [3:0] contador;
logic reset;

/**
Sobre o always_ff:

- A estrutura é always_ff@(posedge VariávelDoClock) begin ~ end
- Posedge significa que o always_ff executa na subida de clock, também existe o negedge, que executa na descida do clock.
  Em questão de funcionamento do codigo não há diferença entre o posedge e o negedge.
  O padrão para a disciplina é usar o posedge, por isso vamos esquecer a existência do negedge.
  Se você estiver curioso pode perguntar a Elmar porque ele não gosta do negedge e qual a diferença.
- A variável do clock padrão na disciplina é o clk_2 que é dado a vocês e vem declarado na parte de código que ja vem pronto
  no top.sv de vocês. Vocês não precisam ativar nada, nem mudar nada no clk_2, apenas usar ele.
  De forma simples, o clock é uma variável que fica alternando entre 0 e 1. Quando vai de 0 para 1 dizemos que é a subida 
  do clock, de forma oposta, de 1 para 0 dizemos que é a descida do clock.
- O always_ff vai executar o código que você colocar nele a cada subida de clock(caso posedge), inicialmente vamos olhar
  pra ele como um laço infinito, pois seu clk_2 vai estar sempre alternando, a não ser que você mude isso, e a cada subida
  o código do always_ff sera executado.

**/

// Always_comb para as entradas
always_comb begin
  reset <= SWI[0];
end

always_ff@(posedge clk_2) begin
  if(reset) begin
    contador <= 0;          // Comportamento de parada do contador(NÃO do clock, o clk_2 continua pulsando, 
                            //mas atribue 0 ao contador a cada subida)
  end
  else begin
    contador <= contador + 1;  

     // você pode ser criativo e fazer varias operações diferentes com seu contador, por exemplo:
   
    /**
      Nesse caso, com o SWI[1] eu escolho se meu contador é crescente ou decrescente, isso é so um exemplo simples,
      use sua criatividade.

    if(SWI[1]) contador <= contador - 1;
    else contador <= contador + 1;
    **/

  end
end


// Always_comb para as saídas
always_comb begin

// Mostrar o clock no LED 7
  LED[7] <= clk_2;


// Mostrar os numeros nos 7 segmentos
  case(contador)
    0: SEG[7:0] <= 'b00111111;
    1: SEG[7:0] <= 'b00000110;
    2: SEG[7:0] <= 'b01011011;
    3: SEG[7:0] <= 'b01001111;
    4: SEG[7:0] <= 'b01100110;
    5: SEG[7:0] <= 'b01101101;
    6: SEG[7:0] <= 'b01111101;
    7: SEG[7:0] <= 'b00000111;
    8: SEG[7:0] <= 'b01111111;
    9: SEG[7:0] <= 'b01101111;
    10: SEG[7:0] <= 'b01110111;
    11: SEG[7:0] <= 'b01111100;
    12: SEG[7:0] <= 'b00111001;
    13: SEG[7:0] <= 'b01011110;
    14: SEG[7:0] <= 'b01111001;
    15: SEG[7:0] <= 'b01110001;
    default: SEG[7:0] <= 'b10000000;
  endcase
end



endmodule
