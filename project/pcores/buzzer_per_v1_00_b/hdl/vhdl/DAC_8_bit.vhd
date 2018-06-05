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
	port(
		i_clk    : in  std_logic;
		in_rst   : in  std_logic;
		i_sample : in  std_logic_vector(31 downto 0);
		o_clk    : out std_logic;
		o_data   : out std_logic;
		o_strobe : out std_logic;
		o_interrupt48khz: out std_logic
	);
end entity DAC_8_bit;

architecture Behavioral of DAC_8_bit is

type state_type is ( IDLE, B7, CLK7, B6, CLK6, B5, CLK5, B4, CLK4, B3, CLK3, B2, CLK2, B1, CLK1, B0, CLK0, STROBE );

signal current_s, next_s: state_type;
signal timer_value: std_logic_vector(7 downto 0);
signal r_sample: std_logic_vector(7 downto 0);
signal timer_value_interrupt: std_logic_vector(11 downto 0);
signal s_flag: std_logic := '0';
signal s_data: std_logic := '0';
signal s_strobe: std_logic := '0';
signal s_clk: std_logic := '0';

signal tc : std_logic;
signal s_interrupt48khz : std_logic;

begin

-- proces za FSM
process (i_clk) 
	begin
		if (in_rst='0') then
			current_s <= IDLE;
		elsif (rising_edge(i_clk)) then 
			current_s <= next_s; --Menjamo next_s u case-ovima
	 end if;
end process;

-- proces za time_value
process (i_clk)
	begin
		if (in_rst = '0') then
			timer_value <= (others => '0');
		elsif (rising_edge(i_clk)) then
			if tc = '1' then -- timer_value sam sebe sredjuje
				timer_value <= (others => '0');
			else
				timer_value<= timer_value + 1;
			end if;
		end if;
end process;
tc <= '1' when timer_value = 99 else '0';



-- proces za interupt handler za c na 48khz
process (i_clk)
	begin
		if (in_rst = '0') then
			timer_value_interrupt <= (others => '0');
		elsif (rising_edge(i_clk)) then
			if s_interrupt48khz = '1' then -- timer_value sam sebe sredjuje
				timer_value_interrupt <= (others => '0');
			else
				timer_value_interrupt<= timer_value_interrupt + 1;
			end if;
		end if;
end process;
s_interrupt48khz <= '1' when timer_value_interrupt = 2083 else '0';

process (i_clk)
	begin
		if (in_rst = '0') then
			timer_value <= (others => '0');
		elsif (rising_edge(i_clk)) then
			if tc = '1' then -- timer_value sam sebe sredjuje
				timer_value <= (others => '0');
			else
				timer_value<= timer_value + 1;
			end if;
		end if;
end process;

-- proces za o_strobe
process (i_clk)
	begin
		if (in_rst = '0') then
			o_strobe <= '0';
		elsif (rising_edge(i_clk)) then
			o_strobe <= s_strobe;
		end if;
end process;

-- proces za o_data
process (i_clk)
	begin
		if (in_rst = '0') then
			o_data <= '0';
		elsif (rising_edge(i_clk)) then
			o_data <= s_data;
		end if;
end process;

-- proces za o_clk
process (i_clk)
	begin
		if (in_rst = '0') then
			o_clk <= '0';
		elsif (rising_edge(i_clk)) then
			o_clk <= s_clk;
		end if;
end process;

-- proces za o_interrupt48khz
process (i_clk)
	begin
		if (in_rst = '0') then
			o_interrupt48khz <= '0';
		elsif (rising_edge(i_clk)) then
			o_interrupt48khz <= s_interrupt48khz;
		end if;
end process;


process(current_s, tc)
begin
	if tc = '1' then
		case current_s is
			when IDLE =>
				next_s <= B7;
			when B7 =>
				next_s <= CLK7;
			when CLK7 =>
				next_s <= B6;
			when B6 =>
				next_s <= CLK6;
			when CLK6 =>
				next_s <= B5;
			when B5 =>
				next_s <= CLK5;
			when CLK5 =>
				next_s <= B4;
			when B4 =>
				next_s <= CLK4;
			when CLK4 =>
				next_s <= B3;
			when B3 =>
				next_s <= CLK3;
			when CLK3 =>
				next_s <= B2;
			when B2 =>
				next_s <= CLK2;
			when CLK2 =>
				next_s <= B1;
			when B1 =>
				next_s <= CLK1;
			when CLK1 =>
				next_s <= B0;
			when B0 =>
				next_s <= CLK0;
			when CLK0 =>
				next_s <= STROBE;
			when STROBE =>
				next_s <= IDLE;
		end case;
	else
		next_s <= current_s;
	end if;
end process;


process(current_s, r_sample)
begin
	case current_s is
		when IDLE =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= '0';
		when B7 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(7);
		when CLK7 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(7);
		when B6 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(6);
		when CLK6 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(6);
		when B5 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(5);
		when CLK5 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(5);		
		when B4 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(4);
		when CLK4 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(4);
		when B3 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(3);
		when CLK3 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(3);
		when B2 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(2);
		when CLK2 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(2);
		when B1 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(1);
		when CLK1 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(1);
		when B0 =>
			s_clk <= '0';
			s_strobe <= '0';
			s_data <= r_sample(0);
		when CLK0 =>
			s_clk <= '1';
			s_strobe <= '0';
			s_data <= r_sample(0);
		when STROBE =>
			s_clk <= '0';
			s_strobe <= '1';
			s_data <= '0';
	end case;
end process;

process (i_clk) 
	begin
		if (in_rst='0') then
			r_sample <= (others => '0');
		elsif (rising_edge(i_clk)) then 
			if tc = '1' and current_s = IDLE then
				r_sample <= i_sample(7 downto 0);
			end if;
	 end if;
end process;

end Behavioral;

