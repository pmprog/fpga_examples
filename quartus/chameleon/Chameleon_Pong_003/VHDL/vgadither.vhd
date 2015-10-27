library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vgadither is
	port (
		pixelclock : in std_logic;
		X : in unsigned(9 downto 0);
		Y : in unsigned(9 downto 0);
		VSync : in std_logic;
		enable : in std_logic;
		iRed : in unsigned(7 downto 0);
		iGreen : in unsigned(7 downto 0);
		iBlue : in unsigned(7 downto 0);
		oRed : out unsigned(4 downto 0);
		oGreen : out unsigned(4 downto 0);
		oBlue : out unsigned(4 downto 0)
	);
end entity;

architecture rtl of vgadither is
	signal field : unsigned (7 downto 0);
	signal red : unsigned(7 downto 0);
	signal green : unsigned(7 downto 0);
	signal blue : unsigned(7 downto 0);
begin

	oRed <= red(7 downto 3);
	oGreen <= green(7 downto 3);
	oBlue <= blue(7 downto 3);

	process(VSync,field)
	begin
		if rising_edge(VSync) then
			field <= field+1;
		end if;
	end process;
	
	process(pixelclock,iRed,iGreen,iBlue,X,Y,field)
	begin
		if(rising_edge(pixelclock)) then
		
			if iRed(7 downto 3)="11111" or enable='0' then
				red <= iRed;
			else
				red <= iRed + ((field(0) xor Y(0)) & (X(0) xor Y(0)) & "0");
--				red <= iRed + (dither(0) & "00");
			end if;
			
			if iGreen(7 downto 3)="11111" or enable='0' then
				green <= iGreen;
			else
				green <= iGreen + ((field(0) xor Y(0)) & (X(0) xor Y(0)) & "0");
--				green <= iGreen + (dither(1) & "00");
			end if;

			if iBlue(7 downto 3)="11111" or enable='0' then
				blue <= iBlue;
			else
				blue <= iBlue + ((field(0) xor Y(0)) & (X(0) xor Y(0)) & "0");
--				blue <= iBlue + (dither(1) & "00");
			end if;
			
		end if;
	end process;
end architecture;
