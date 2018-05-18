----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:02 05/15/2018 
-- Design Name: 
-- Module Name:    DAC_8_bit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC_8_bit is
    Port ( i_clk : in  STD_LOGIC;
           in_rst : in  STD_LOGIC;
			  i_reg : in std_logic_vector(31 downto 0);
           o_strobe : out  STD_LOGIC;
           o_clk : out  STD_LOGIC;
           o_data : out  STD_LOGIC);
end entity DAC_8_bit;

architecture Behavioral of DAC_8_bit is

type state_type is ( IDLE, B7, CLK7, B6, CLK6, B5, CLK5, B4, CLK4, B3, CLK3, B2, CLK2, B1, CLK1, B0, CLK0, STROBE );

signal current_s: state_type;

--signal timer_value: std_logic_vector(31 downto 0) := (others => '0');
--signal b2ip=_value: std_logic_vector(7 downto 0):= (others => '0');

signal timer_value: std_logic_vector(7 downto 0) := (others => '0');
signal s_flag: std_logic;

--signal next_timer_value: std_logic_vector(31 downto 0);
--signal next_b2ip_value: std_logic_vector(7 downto 0);

--signal s_data: std_logic;
--signal s_strobe: std_logic;

begin

process (i_clk) -- Razdvojimo procese za reset, state i clock 
	begin
		if (in_rst='0') then
			current_s <= IDLE;
			timer_value<=(others => '0');
			
			s_strobe <= '0';
			o_data<='0';
			s_flag <= '0';
			
			
		elsif (rising_edge(i_clk)) then 
			current_s <= next_s; --Menjamo next_s u case-ovima
		
			if ( timer_value = 99 ) then -- timer_value sam sebe sredjuje, ne treba nam s_flag
			
				timer_value <= (others => '0');
				
			else
			
				timer_value<= timer_value + 1;
				
			end if;
		
			
	 end if;
end process;




s_flag <= '1' when timer_value = 99 else '0';



process(current_s, i_reg, timer_value)

	begin
	
		
		case current_s is

		when IDLE =>
			next_s <= B7;
		
			
		when B7 =>
		if (timer_value=99) then
			s_data <= i_reg(7);
			current_s <= CLK7;
		else
			current_s <= B7;
			s_flag <= '0';
		end if;
		
		when CLK7 => -- OVDE DIZEMO O_CLK na '1' da bi DAC znao sta se desava
			s_flag <= '0';
			current_s <= B6;
		
		
		when B6 => -- OVDE SPUSTAMO O_CLK na '0' da bi DAC znao sta se desava
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B5;
		end if;
			
		when B5 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B4;
		end if;
			
		when B4 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B3;
		end if;
			
		when B3 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B2;
		end if;
			
		when B2 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B1;
		end if;
			
		when B1 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= B0;
		end if;
			
		when B0 =>
		if (timer_value=99) then
			s_flag <= '1';
			current_s <= STROBE;
		end if;
		
		when STROBE =>
		if (timer_value=99) then
			s_flag <= '1';
			s_strobe <= '1';
			current_s <= IDLE;
		end if;
		
		when others =>
			current_s <= IDLE;

			
	end case;
		
end process;


end Behavioral;

