library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Assignment2TB is
end Assignment2TB;

architecture Behavioral of Assignment2TB is

    -- Signal declarations
    signal TCKtb, TMStb, resettb: std_logic; -- Clock and control signals
    signal TDItb, TDOtb: std_logic;          -- Serial data in/out
    signal clktb: std_logic;                 -- Simulation clock
    signal input_register: std_logic_vector(31 downto 0) := x"DEADBEEF";
    signal output_register: std_logic_vector(31 downto 0);
    constant clk_periodtb : time := 10 ns;   -- Clock period
    signal curr_dr, next_dr : std_logic_vector(31 downto 0) := x"C0FFEE00"; -- Registers

    component JTAG_FSM
        Port (
            TCK : in std_logic;        -- Clock signal for the FSM
            TMS : in std_logic;        -- Test Mode Select signal
            reset : in std_logic;      -- Reset signal
            TDI : out std_logic;       -- Serial data output (Test Data In)
            TDO : in std_logic         -- Serial data input (Test Data Out)
        );
    end component;

begin

    -- Instantiate the FSM
    uut: JTAG_FSM
        Port map (
            TCK => TCKtb,
            TMS => TMStb,
            reset => resettb,
            TDI => TDItb,
            TDO => TDOtb
        );
        
        
        
          -- Clock generation
    clock_process: process
    begin
        clktb <= '0';
        wait for clk_periodtb/2;
        clktb <= '1';
        wait for clk_periodtb/2;
    end process;

    -- Test process to apply stimulus
    stimulus: process
    begin
        -- Initialize signals
        resettb <= '1'; -- Reset FSM
        TMStb <= '0'; -- Set TMS to 0 (default state)
        wait for clk_periodtb;
        
        -- Release reset
        resettb <= '0';
        wait for clk_periodtb;

        -- 1. Enter Run-Test/Idle
        TMStb <= '0'; -- TMS = 0, move to RunTestIdle
        wait for clk_periodtb;

        -- 2. Move to Select DR-Scan state
        TMStb <= '1'; -- TMS = 1, move to SelectDRscan
        wait for clk_periodtb;

        -- 3. Move to Capture DR state
        TMStb <= '0'; -- TMS = 0, move to CaptureDR
        wait for clk_periodtb;

        -- 4. Move to Shift DR state
        TMStb <= '0'; -- TMS = 0, move to ShiftDR
        wait for clk_periodtb;

        -- 5. Start shifting 32-bit data (simulate TDO feeding DEADBEEF and capturing C0FFEE00)
        for i in 0 to 31 loop
            TDOtb <= input_register(31 - i); -- Inject DEADBEEF serially into TDO
            wait for clk_periodtb;
        end loop;

        -- 6. Move to Exit1 DR state
        TMStb <= '1'; -- TMS = 1, move to Exit1DR
        wait for clk_periodtb;

        -- 7. Move to Update DR state
        TMStb <= '1'; -- TMS = 1, move to UpdateDR
        wait for clk_periodtb;

        -- Check if the register has been updated
        assert curr_dr = input_register
            report "Test failed: Register not updated with DEADBEEF"
            severity error;

        -- Move to Run-Test/Idle after the update
        TMStb <= '0';
        wait for clk_periodtb;

        -- 8. Move back to Shift DR to check if the updated register shifts correctly
        TMStb <= '1'; -- TMS = 1, move to SelectDRscan
        wait for clk_periodtb;

        -- 9. Capture DR again
        TMStb <= '0'; -- TMS = 0, move to CaptureDR
        wait for clk_periodtb;

        -- 10. Shift DR (should now output DEADBEEF from curr_dr)
        TMStb <= '0'; -- TMS = 0, shift DR state
        for i in 0 to 31 loop
            assert TDItb = input_register(31 - i)
                report "Shifted output mismatch"
                severity error;
            wait for clk_periodtb;
        end loop;

        -- Test complete
        wait;
    end process;

end Behavioral;





