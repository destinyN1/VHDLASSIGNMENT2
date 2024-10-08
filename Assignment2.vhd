library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration for the JTAG FSM
entity JTAG_FSM is
    Port (
        TCK : in std_logic;        -- Clock signal for the FSM (Test Clock)
        TMS : in std_logic;         -- Test Mode Select input signal for state transitions
        reset : in std_logic;          -- Reset signal to initialize FSM to the TestLogicReset state
        TDI : out std_logic:='0';        -- Serial data output pin (Test Data In)
        TDO : in std_logic;   -- Serial data input pin (Test Data Out)
    CaptureDRCheck: in std_logic
        
    );
    
end JTAG_FSM;

architecture Behavioral of JTAG_FSM is

    -- Enumeration of the 16 JTAG TAP states
    type state_type is (
        TestLogicReset, RunTestIdle, SlctDRscan, CaptureDR, ShiftDR,
        Exit1DR, PauseDR, Exit2DR, UpdateDR, SlctIRscan,
        CaptureIR, ShiftIR, Exit1IR, PauseIR, Exit2IR, UpdateIR
    );

    -- Signals to hold the current and next states of the FSM
    signal current_state, next_state : state_type;

    -- 32-bit internal registers for data handling
    signal curr_local_dr_reg : std_logic_vector(31 downto 0);  
    signal next_local_dr_reg : std_logic_vector(31 downto 0);
    signal TDOREG: std_logic_vector(31 downto 0):= x"DEADBEEF";
   

    -- 32-bit counter for tracking shifts during the ShiftDR state
 signal  bit_counter : integer range 0 to 31;
  
    

begin

    -- Combinational process to determine the next state based on the current state and TMS input
   State_Logic_p: process(bit_counter,current_state, TMS)
    begin
    
    
    --default assignments to avoid latches
    next_state <= current_state;
    
    
        case current_state is
                               --State: TestLogicReset
            when TestLogicReset =>            
                if TMS = '0' then
                    next_state <= RunTestIdle;  -- Transition to RunTestIdle if TMS is 0
                else
                    next_state <= TestLogicReset;  -- Remain in TestLogicReset if TMS is 1
                end if;

            -- State: RunTestIdle
            when RunTestIdle =>
               
                if TMS = '1' then
                    next_state <= SlctDRscan;  -- Transition to Select DR Scan if TMS is 1
                else
                    next_state <= RunTestIdle;  -- Remain in RunTestIdle if TMS is 0
                end if;

            -- State: Select DR Scan
            when SlctDRscan =>
           
                if TMS = '1' then
                    next_state <= SlctIRscan;  -- Transition to Select IR Scan if TMS is 1
                else
                    next_state <= CaptureDR;  -- Transition to CaptureDR if TMS is 0
                end if;

            -- State: CaptureDR
            when CaptureDR =>
             
                if TMS = '1' then
                    next_state <= Exit1DR;  -- Transition to Exit1DR if TMS is 1
                else
                    next_state <= ShiftDR;  -- Transition to ShiftDR if TMS is 0
                end if;

            -- State: ShiftDR
            when ShiftDR =>
            
                if TMS = '1' then
                    next_state <= Exit1DR;  -- Transition to Exit1DR if TMS is 1
                else
                    next_state <= ShiftDR;  -- Remain in ShiftDR if TMS is 0
                end if;

            -- State: Exit1DR
            when Exit1DR =>
           
                if TMS = '1' then
                    next_state <= UpdateDR;  -- Transition to UpdateDR if TMS is 1
                else
                    next_state <= PauseDR;  -- Transition to PauseDR if TMS is 0
                end if;

            -- State: PauseDR
            when PauseDR =>
            
                if TMS = '1' then
                    next_state <= Exit2DR;  -- Transition to Exit2DR if TMS is 1
                else
                    next_state <= PauseDR;  -- Remain in PauseDR if TMS is 0
                end if;

            -- State: Exit2DR
            when Exit2DR =>
            
                if TMS = '1' then
                    next_state <= UpdateDR;  -- Transition to UpdateDR if TMS is 1
                else
                    next_state <= ShiftDR;  -- Transition back to ShiftDR if TMS is 0
                end if;

            -- State: UpdateDR
            when UpdateDR =>
            
                if TMS = '1' then
                    next_state <= SlctDRscan;  -- Transition to Select DR Scan if TMS is 1
                else
                    next_state <= RunTestIdle;  -- Transition to RunTestIdle if TMS is 0
                end if;

            -- State: Select IR Scan
            when SlctIRscan =>
            
                if TMS = '1' then
                    next_state <= TestLogicReset;  -- Transition to TestLogicReset if TMS is 1
                else
                    next_state <= CaptureIR;  -- Transition to CaptureIR if TMS is 0
                end if;

            -- State: CaptureIR
            when CaptureIR =>
           
                if TMS = '1' then
                    next_state <= Exit1IR;  -- Transition to Exit1IR if TMS is 1
                else
                    next_state <= ShiftIR;  -- Transition to ShiftIR if TMS is 0
                end if;

            -- State: ShiftIR
            when ShiftIR =>
           
                if TMS = '1' then
                    next_state <= Exit1IR;  -- Transition to Exit1IR if TMS is 1
                else
                    next_state <= ShiftIR;  -- Remain in ShiftIR if TMS is 0
                end if;

            -- State: Exit1IR
            when Exit1IR =>
          
                if TMS = '1' then
                    next_state <= UpdateIR;  -- Transition to UpdateIR if TMS is 1
                else
                    next_state <= PauseIR;  -- Transition to PauseIR if TMS is 0
                end if;

            -- State: PauseIR
            when PauseIR =>
          
                if TMS = '1' then
                    next_state <= Exit2IR;  -- Transition to Exit2IR if TMS is 1
                else
                    next_state <= PauseIR;  -- Remain in PauseIR if TMS is 0
                end if;

            -- State: Exit2IR
            when Exit2IR =>
           
                if TMS = '1' then
                    next_state <= UpdateIR;  -- Transition to UpdateIR if TMS is 1
                else
                    next_state <= ShiftIR;  -- Transition back to ShiftIR if TMS is 0
                end if;

            -- State: UpdateIR
            when UpdateIR =>
           
                if TMS = '1' then
                    next_state <= SlctDRscan;  -- Transition to Select DR Scan if TMS is 1
                else
                    next_state <= RunTestIdle;  -- Transition to RunTestIdle if TMS is 0
                end if;

            -- Default case (should not occur in normal operation)
            when others =>
            
                next_state <= TestLogicReset;  -- Reset to a known state in case of an invalid state
        end case;
    end process;

    -- Sequential process to update the current state on the rising edge of TCK
    State_reg_p: process(CaptureDRCheck, bit_counter,TCK, reset)
    begin
        if reset = '1' then
             --Reset state and registers
            current_state <= TestLogicReset;
 
                            
        elsif rising_edge(TCK) and reset = '0' then
            -- State Transition: Update current state
            current_state <= next_state;
         
            end if;
end process;

    -- Data Shifting Process
Data_Shift_p: process(CaptureDRCheck, bit_counter, TCK)
begin

    if rising_edge(TCK) then
        
        if current_state = TestLogicReset then
             curr_local_dr_reg <= x"C0FFEE00";
            next_local_dr_reg <= (others => '0');
            end if;
        
       
        
        if current_state = ShiftDR then
     
            -- Shift out data from curr_local_dr_reg to TDI (MSB first)
            TDI <= curr_local_dr_reg(31 - bit_counter);
          

            -- Shift in data from TDO into next_local_dr_reg (MSB first)
            next_local_dr_reg(31 - bit_counter) <= TDO;
        end if;

        -- Register Update Logic in CaptureDR state
        if current_state = CaptureDR and CaptureDRCheck = '1' then 
            -- Update curr_local_dr_reg with the value in next_local_dr_reg
            curr_local_dr_reg <= next_local_dr_reg;
        
        end if;
    end if;
end process;


-- Counter Process
Counter_p: process(bit_counter, TCK, reset)
begin
    if reset = '1' then
        bit_counter <= 0;
   elsif rising_edge(TCK) then
        if current_state = ShiftDR then
    
            if bit_counter < 31 then
                bit_counter <= bit_counter + 1;
            else
                bit_counter <= 0;  -- Reset after 32 bits
            end if;
        else
            bit_counter <= 0;  -- Reset counter when not in ShiftDR
        end if;
    end if;
end process;



end Behavioral;
