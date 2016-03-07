library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- -----------------------------------------------------------------------

entity simple_button_to_led is
	port (
		clk : in std_logic;

		button_one : in std_logic;
		button_two : in std_logic;
		led_one : out std_logic;
		led_two : out std_logic
	);
end entity;