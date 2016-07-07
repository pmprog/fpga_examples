library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity fakemem is
	port (
		clk : in std_logic;
		data : inout unsigned(15 downto 0);
		address : in unsigned(15 downto 0);
		write_en : out std_logic
	);
end entity;

-- -----------------------------------------------------------------------

architecture fakememrtl of fakemem is
begin

	process(clk)
	begin
		if rising_edge(clk) then
			data <= address;
		end if;
	end process;

end architecture;
