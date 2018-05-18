-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    RESET : in std_logic;
    CLK_P : in std_logic;
    CLK_N : in std_logic;
    buzzer_per_0_out_pwm_pin : out std_logic;
    buzzer_per_0_o_strobe_pin : out std_logic;
    buzzer_per_0_o_clk_pin : out std_logic;
    buzzer_per_0_o_data_pin : out std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      RESET : in std_logic;
      CLK_P : in std_logic;
      CLK_N : in std_logic;
      buzzer_per_0_out_pwm_pin : out std_logic;
      buzzer_per_0_o_strobe_pin : out std_logic;
      buzzer_per_0_o_clk_pin : out std_logic;
      buzzer_per_0_o_data_pin : out std_logic
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      RESET => RESET,
      CLK_P => CLK_P,
      CLK_N => CLK_N,
      buzzer_per_0_out_pwm_pin => buzzer_per_0_out_pwm_pin,
      buzzer_per_0_o_strobe_pin => buzzer_per_0_o_strobe_pin,
      buzzer_per_0_o_clk_pin => buzzer_per_0_o_clk_pin,
      buzzer_per_0_o_data_pin => buzzer_per_0_o_data_pin
    );

end architecture STRUCTURE;

