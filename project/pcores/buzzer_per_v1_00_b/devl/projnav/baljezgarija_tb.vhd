--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:43:54 06/19/2016
-- Design Name:   
-- Module Name:   C:/Users/student/Downloads/lab5-master/lab5-master/pcores/buzzer_per_v1_00_b/devl/projnav/baljezgarija_tb.vhd
-- Project Name:  buzzer_per
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: baljezgarija
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY baljezgarija_tb IS
END baljezgarija_tb;
 
ARCHITECTURE behavior OF baljezgarija_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT baljezgarija
    PORT(
         i_slv_0 : IN  std_logic_vector(31 downto 0);
         i_slv_1 : IN  std_logic_vector(31 downto 0);
         i_slv_2 : IN  std_logic_vector(31 downto 0);
         i_slv_3 : IN  std_logic_vector(31 downto 0);
         i_bus2ip_clk : IN  std_logic;
         i_bus2ip_rst : IN  std_logic;
         o_pwm : OUT  std_logic;
         o_irq : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_slv_0 : std_logic_vector(31 downto 0) := (others => '0');
   signal i_slv_1 : std_logic_vector(31 downto 0) := (others => '0');
   signal i_slv_2 : std_logic_vector(31 downto 0) := (others => '0');
   signal i_slv_3 : std_logic_vector(31 downto 0) := (others => '0');
   signal i_bus2ip_clk : std_logic := '0';
   signal i_bus2ip_rst : std_logic := '0';

 	--Outputs
   signal o_pwm : std_logic;
   signal o_irq : std_logic;

   -- Clock period definitions
   constant i_bus2ip_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: baljezgarija PORT MAP (
          i_slv_0 => i_slv_0,
          i_slv_1 => i_slv_1,
          i_slv_2 => i_slv_2,
          i_slv_3 => i_slv_3,
          i_bus2ip_clk => i_bus2ip_clk,
          i_bus2ip_rst => i_bus2ip_rst,
          o_pwm => o_pwm,
          o_irq => o_irq
        );

   -- Clock process definitions
   i_bus2ip_clk_process :process
   begin
		i_bus2ip_clk <= '0';
		wait for i_bus2ip_clk_period/2;
		i_bus2ip_clk <= '1';
		wait for i_bus2ip_clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		i_bus2ip_rst<='0';
      wait for 100 ns;
		i_bus2ip_rst<='1';
			i_slv_0<="00000000000000000000000000000000";
			i_slv_1<="00000000000000000000000000000000";
			
			i_slv_2<="00000000000000000000000000000001";
			i_slv_3<="00000000000000000000000000000001";

      wait for i_bus2ip_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
