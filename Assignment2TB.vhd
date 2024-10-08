-- Testbench for JTAG_FSM
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_JTAG_FSM IS
    -- Testbench has no ports
END tb_JTAG_FSM;

ARCHITECTURE behavior OF tb_JTAG_FSM IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT JTAG_FSM
    PORT(
         TCK   : IN  std_logic;       -- Clock signal for the FSM (Test Clock)
         TMS   : IN  std_logic;       -- Test Mode Select input signal for state transitions
         reset : IN  std_logic;       -- Reset signal to initialize FSM to the TestLogicReset state
         TDI   : OUT std_logic;       -- Serial data output pin (Test Data In)
         TDO   : IN  std_logic;      -- Serial data input pin (Test Data Out)
         CaptureDRCheck:  in std_logic
         

    );
    END COMPONENT;
    
    -- Signals to connect to UUT
    SIGNAL TCK    : std_logic := '0';
    SIGNAL TMS    : std_logic := '0';
    SIGNAL reset  : std_logic := '0';
    SIGNAL TDI    : std_logic;
    SIGNAL TDO    : std_logic := '0';
    SIGNAL TDOREG: std_logic_vector(31 downto 0):= x"DEADBEEF";
    signal  bit_countertb : integer range 0 to 31:=0;
    SIGNAL TDOtb    : std_logic := '0';
    SIGNAL   CaptureDRCheck:  std_logic:='0';


type state_type is (
        TestLogicReset, RunTestIdle, SlctDRscan, CaptureDR, ShiftDR,
        Exit1DR, PauseDR, Exit2DR, UpdateDR, SlctIRscan,
        CaptureIR, ShiftIR, Exit1IR, PauseIR, Exit2IR, UpdateIR
    );
    
signal current_state, next_state : state_type;
    -- Clock period definition
    CONSTANT clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: JTAG_FSM PORT MAP (
          TCK    => TCK,
          TMS    => TMS,
          reset  => reset,
          TDI    => TDI,
          TDO    => TDO,
          CaptureDRCheck => CaptureDRCheck
       
        );

    -- Clock Generation Process
    clk_process :process
    begin
        TCK <= '1';
        WAIT FOR clk_period/2;
        TCK <= '0';
        WAIT FOR clk_period/2;
    end process;



 
stimulus: process
begin 
    -- Initialize Inputs
    reset <= '1';
    TMS   <= '1';
    
    wait for 20 ns;  -- Hold reset high for 20 ns
    
    --Run Test Idle
    reset<='0';
    TMS<='0';
    wait for 10 ns;
    
    --Select DR scan
    TMS<='1'; 
    wait for 10ns;
    
    --Capture DR
    TMS<='0';
    wait for 20ns;
    
    --ShiftDR

    TMS<='0';
   
    WAIT for 400 ns;
   
   --Exit1 DR 
   TMS <='1';
   wait for clk_period;
   
   --Pause DR
   TMS <='0';
   wait for clk_period;
   
   --Exit2 DR
   TMS <='1';
   wait for clk_period;
   
   --Update DR 
   TMS <='1';
   wait for clk_period;
   
   --Select DR Scan
   TMS <='1';
   wait for clk_period;
    
    --Capture DR
   TMS <='0';
   CaptureDRCheck <= '1';
   wait for clk_period; 
   
   wait for 320 ns;

end process;

 tb_inc: process
begin 
 wait for 70 ns;
  for i in 0 to 31 loop
   TDO <= TDOREG(31-bit_countertb);
   bit_countertb <= bit_countertb + 1;
   
    wait for  clk_period;
     end loop;
     bit_countertb<= 0;
     wait;
     end process;

end behavior;