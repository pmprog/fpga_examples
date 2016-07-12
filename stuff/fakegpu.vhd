library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity fakegpu is
	port (
		clk : in std_logic;
		
		bus_req : out std_logic;
		bus_ack : in std_logic;
		
		ram_data : in unsigned(15 downto 0);
		ram_address : out unsigned(15 downto 0);
		
		vga_r : out unsigned(3 to 0);
		vga_g : out unsigned(3 to 0);
		vga_b : out unsigned(3 to 0);
		vga_hs : out std_logic;
		vga_vs : out std_logic
	);
end entity;

-- -----------------------------------------------------------------------

architecture fakegpurtl of fakegpu is
begin

	process(clk)
	begin
		if rising_edge(clk) then
			
		end if;
	end process;

end architecture;
