library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- A simple PWM output running at the fastest clock available.
-- Currently uses 8-bits - could probably handle 12-bits and still retain 20KHz+ resolution
-- Could also try using a multi-tier PWM scheme to spread error in the time domain
-- to give 16-bit output without sacrificing high frequency response.

entity soundchannel is
	port (
		clk : in std_logic;
		amplitude : in unsigned(7 downto 0);
		pwm : out std_logic
	);
end soundchannel;


architecture rtl of soundchannel is
	signal acc : unsigned (8 downto 0);	-- 9-bit accumulator (8-bit plus overflow)
begin
	process(clk, amplitude)
	begin
		if rising_edge(clk) then
			-- Mask off any overflow, then add amplitude to accumulator
			acc <= ("0" & acc(7 downto 0)) + ("0" & amplitude);
		end if;
	end process;
	pwm <= acc(8);	-- The overflow bit governs the PWM output
end rtl;
