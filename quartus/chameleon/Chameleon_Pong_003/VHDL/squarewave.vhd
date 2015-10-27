library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- A simple squarewave generator.
-- Currently includes a sound output channel.
-- TODO: create a simple summing mixer to allow multiple channels
-- to sound simultaneously. 
-- (Or could just flit between them)

entity squarewave is
	port (
		clk : in std_logic;	-- Fastest clock available
		period : in unsigned(15 downto 0); -- Number of clocks in each cycle
		amplitude : in unsigned(7 downto 0); -- Amplitude of generated singla (8-bits)
		outpwm : out std_logic -- The signal which will carry the generated 1-bit output.
	);
end entity;

architecture rtl of squarewave is
	signal cnt : unsigned(23 downto 0) := TO_UNSIGNED(0,24) ;	-- Counter - used to set pitch
	signal amp : unsigned(7 downto 0); -- Generated signal fed to sound channel
begin

	outchannel : entity work.soundchannel
	port map (
		clk => clk,
		amplitude => amp,
		pwm => outpwm
	);

	process(clk)
	begin
		if rising_edge(clk) then
			if cnt < (period & "00000") then
				amp <= amplitude;	-- Output is high (modulated) for the first half of the cycle
			else
				amp <= TO_UNSIGNED(0,8);
			end if;
			if cnt >= (period & "000000") then  -- End of the second half of the cycle
				cnt <= TO_UNSIGNED(0,24);	-- Reset counter;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	
end architecture;
