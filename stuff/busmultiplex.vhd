
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity busmultiplex is
	port (
		clk : in std_logic;
		b_enable : in std_logic;
		ina_address : in unsigned(15 downto 0);
		inb_address : in unsigned(15 downto 0);
		out_address : out unsigned(15 downto 0)
	);
end entity;

-- -----------------------------------------------------------------------

architecture busmultiplexrtl of busmultiplex is
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if b_enable = '1' then
				out_address <= inb_address;
			else
				out_address <= ina_address;
			end if;
		end if;
	end process;

end architecture;
 
