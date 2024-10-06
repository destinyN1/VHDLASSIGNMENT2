library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Assignment2TB is
end Assignment2TB;

architecture Behavioral of Assignment2TB is

    -- Signal declarations
    signal TCK, TMS, reset: std_logic; -- Clock and control signals
    signal TDO: std_logic_vector(31 downto 0);
    signal TDI: std_logic;     -- Serial data in/out             
    signal curr_local_dr_reg: std_logic_vector(31 downto 0);
    signal next_local_dr_reg: std_logic_vector(31 downto 0);
    constant clk_periodtb : time := 50 ns; --clk period
   

    component JTAG_FSM
        Port (
            TCK : in std_logic;        -- Clock signal for the FSM
            TMS : in std_logic;        -- Test Mode Select signal
            reset : in std_logic;      -- Reset signal
            TDI : out std_logic;     -- Serial data output (Test Data In)
            TDO : in std_logic_vector(31 downto 0)   -- Serial data input (Test Data Out)
        );
    end component;

begin

    -- Instantiate the FSM
    uut: JTAG_FSM
        Port map (
            TCK => TCK,
            TMS => TMS,
            reset => reset,
            TDI => TDI,
            TDO => TDO
        );
        
        
        
          -- Clock generation
    clock_process: process
    begin
        TCK <= '0';
        wait for clk_periodtb/2;
        TCK <= '1';
        wait for clk_periodtb/2;
    end process;

    -- Test process to apply stimulus
    stimulus: process
    begin
        -- Initialize signals
        reset <= '1'; -- Reset FSM
        TMS <= '0'; -- Set TMS to 0 (default state)
        wait for clk_periodtb;
        
        -- Release reset
        reset <= '0';
        wait for clk_periodtb;

        -- 1. Enter Run-Test/Idle
        TMS <= '0'; -- TMS = 0, move to RunTestIdle
        wait for clk_periodtb;

        -- 2. Move to Select DR-Scan state
        TMS <= '1'; -- TMS = 1, move to SelectDRscan
        wait for clk_periodtb;

        -- 3. Move to Capture DR state
        TMS <= '0'; -- TMS = 0, move to CaptureDR
        wait for clk_periodtb;

        -- 4. Move to Shift DR state
        TMS <= '0'; -- TMS = 0, move to ShiftDR
        wait for 32*clk_periodtb;

        -- 5. Start shifting 32-bit data (simulate TDO feeding DEADBEEF and capturing C0FFEE00)
        

        -- 6. Move to Exit1 DR state
        TMS <= '1'; -- TMS = 1, move to Exit1DR
        wait for clk_periodtb;

        -- 7. Move to Update DR state
        TMS <= '1'; -- TMS = 1, move to UpdateDR
        wait for clk_periodtb;

        -- Check if the register has been updated
--        assert curr_dr = input_register
--            report "Test failed: Register not updated with DEADBEEF"
--            severity error;

        -- Move to Run-Test/Idle after the update
        TMS <= '0';
        wait for clk_periodtb;

        -- 8. Move back to Shift DR to check if the updated register shifts correctly
        TMS <= '1'; -- TMS = 1, move to SelectDRscan
        wait for clk_periodtb;

        -- 9. Capture DR again
        TMS <= '0'; -- TMS = 0, move to CaptureDR
        wait for clk_periodtb;

        -- 10. Shift DR (should now output DEADBEEF from curr_dr)
        TMS <= '0'; -- TMS = 0, shift DR state
       

        -- Test complete
        wait for 1100ns;
    end process;

end Behavioral;





