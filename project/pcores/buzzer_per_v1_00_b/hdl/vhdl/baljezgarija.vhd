----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:27:12 06/19/2016 
-- Design Name: 
-- Module Name:    baljezgarija - Behavioral 
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

entity baljezgarija is
    Port ( i_slv_0 : in  STD_LOGIC_VECTOR (31 downto 0);
           i_slv_1 : in  STD_LOGIC_VECTOR (31 downto 0);
           i_slv_2 : in  STD_LOGIC_VECTOR (31 downto 0);
           i_slv_3 : in  STD_LOGIC_VECTOR (31 downto 0);
           i_bus2ip_clk : in  STD_LOGIC;
			  --
			  i_bus2ip_rst: in STD_LOGIC;
			  --
           o_pwm : out  STD_LOGIC;
           o_irq : out  STD_LOGIC);
end entity baljezgarija;

architecture Behavioral of baljezgarija is

--user signals
  
  type state_type is (idle, upcount, downcount, processing);
  type state_type2 is (idle, upcount, processing);
  
  signal timer_value :std_logic_vector(31 downto 0);
  signal b2ip_value :std_logic_vector(7 downto 0);
  
  signal next_timer_value: std_logic_vector(31 downto 0);
  signal next_b2ip_value: std_logic_vector(7 downto 0);
  
  signal current_s,next_s: state_type;
  
  signal next_output_value:std_logic;
  signal output_value: std_logic;
  
  signal next_my_timer_irq:std_logic;
  
  signal timer_reset_sinc: std_logic;
  
  --for timer 2
  
  signal timer2_value: std_logic_vector(31 downto 0);
  --b2ip_value is shared
  signal next_timer2_value: std_logic_vector(31 downto 0);
  signal current_s2, next_s2: state_type2;

begin

 process (i_bus2ip_clk)
	begin
		if (i_bus2ip_rst='0') then
			current_s <= idle;
			timer_value<=(others => '0');
			b2ip_value<=(others => '0');
			o_irq <= '0';
			output_value<='0';
			
			--timer2 
			timer2_value<=(others => '0');
			current_s2<=idle;
			
		elsif (rising_edge(i_bus2ip_clk)) then 
			b2ip_value<=next_b2ip_value;
			timer_value<=next_timer_value;
			current_s <= next_s;
			output_value<=next_output_value;
			o_irq <= next_my_timer_irq;
			
			--timer2
			timer2_value<=next_timer2_value;
			current_s2<=next_s2;
			
	 end if;
end process;

--state machine
process(current_s, i_slv_2, i_slv_1, i_slv_0, b2ip_value, timer_value, timer_reset_sinc)

	begin
	next_s<=current_s;
	next_b2ip_value<=b2ip_value+1;
	next_timer_value<=timer_value;
	next_output_value<=output_value;
	
	
		case current_s is

		when idle =>
			if (i_slv_2(0)='1') then 
				next_s<=upcount;
			else 
				next_s<=idle;
			end if;

		when upcount =>
			if (b2ip_value=99) then
				next_b2ip_value<=(others=>'0');
				if(timer_value=i_slv_1) then
					next_output_value<='1';
					next_timer_value<=timer_value-1;
				end if;
				if(timer_value=i_slv_0) then
					next_s<=downcount;
				else
					next_timer_value<=timer_value+1;
				end if;
			end if;
		when downcount=>
			if (b2ip_value=99) then
				next_b2ip_value<=(others=>'0');
				if(timer_value=i_slv_1) then
					next_output_value<='0';
					next_timer_value<=timer_value+1;
				end if;
				if(timer_value=0) then
					next_s<=upcount;
				else
					next_timer_value<=timer_value-1;
				end if;
			end if;
		when processing=>
			next_b2ip_value<=(others=>'0');
			next_output_value<='0';
			next_timer_value<=(others=>'0');
			if(i_slv_2(1)='1') then
				next_s<=idle;
			end if;
			
		end case;
		
		if (timer_reset_sinc='1') then
			next_s<=processing;
		end if;
	end process;
  
  process(current_s2, i_slv_2, i_slv_3, b2ip_value, timer2_value)
  
	begin
		next_s2<=current_s2;
		next_timer2_value<=timer2_value;
		next_my_timer_irq<='0';
		timer_reset_sinc <= '0';
		
		case current_s2 is
		
		 when idle =>
			if (i_slv_2(0)='1') then 
				next_s2<=upcount;
			else 
				next_s2<=idle;
			end if;
		 when upcount =>
			if(b2ip_value=99) then
				if(timer2_value=i_slv_3) then
					next_timer2_value<=(others=>'0');
					next_s2<=processing;
					next_my_timer_irq<='1';
					timer_reset_sinc <= '1';
					--permission change
				else
					next_timer2_value<=timer2_value+1;
				end if;
			end if;
		 when processing =>
			if(i_slv_2(1)='1') then
				next_s2<=idle;
			end if;
		end case;


  end process;

  o_pwm<=output_value;
  
  
  
  
  
  
  

end Behavioral;

