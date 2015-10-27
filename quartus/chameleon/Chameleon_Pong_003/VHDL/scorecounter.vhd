library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- simple two-digit BCD score counter

entity scorecounter is
	port(
		clk : in std_logic;
		clear : in std_logic;
		counter : out unsigned(7 downto 0)
	);
end entity;

architecture rtl of scorecounter is
	signal cnt : unsigned(7 downto 0) := "00000000";
begin
	process(clk,cnt)
	begin
		counter <= cnt;
		if rising_edge(clk) then
			if(cnt(3 downto 0) = "1001") then
				cnt <= (cnt and "11110000") + "00010000";
			else
				cnt <= cnt+"00000001";
			end if;
		end if;
		if clear='1' then
			cnt <= "00000000";
		end if;
	end process;

end architecture;
