library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- -----------------------------------------------------------------------

entity simple_start is
	port (
		clk : in std_logic;

		button_one : out std_logic;
		button_two : out std_logic
	);
end entity;