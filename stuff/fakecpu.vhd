library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity fakecpu is
	port (
		clk : in std_logic;
		
		gpu_bus_req : in std_logic;
		gpu_bus_ack : out std_logic;
		
		ram_data : inout unsigned(15 downto 0);
		ram_address : out unsigned(15 downto 0);
		ram_write_en : out std_logic
	);
end entity;

-- -----------------------------------------------------------------------

architecture fakecpurtl of fakecpu is
begin

	process(clk)
	begin
		if rising_edge(clk) then
			
		end if;
	end process;

end architecture;
