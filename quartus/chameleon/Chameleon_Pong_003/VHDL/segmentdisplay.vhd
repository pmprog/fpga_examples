library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Need a 7-bit number to represent segments
--   000
--  1   2
--   333
--  4   5
--   666
--  0: 1110111   1: 0100100   2: 1011101   3: 1101101   4: 0101110 
--  5: 1101011   6: 1111011   7: 0100101   8: 1111111   9: 0101111


entity segmentdisplay is
	generic (
		top : unsigned(11 downto 0);
		lft : unsigned(11 downto 0)
	);
	port (
		digit : in unsigned(3 downto 0);
		xpos : in unsigned(11 downto 0);
		ypos : in unsigned(11 downto 0);
		draw : out boolean
	);
end entity;

architecture rtl of segmentdisplay is
	signal trans : std_logic_vector(6 downto 0);
	signal dx : unsigned(11 downto 0);
	signal dy : unsigned(11 downto 0);
begin
	process(digit)
	begin
		case digit is
			when "0000" =>
				trans<="1110111";
			when "0001" =>
				trans<="0100100";
			when "0010" =>
				trans<="1011101";
			when "0011" =>
				trans<="1101101";
			when "0100" =>
				trans<="0101110";
			when "0101" =>
				trans<="1101011";
			when "0110" =>
				trans<="1111011";
			when "0111" =>
				trans<="0100101";
			when "1000" =>
				trans<="1111111";
			when "1001" =>
				trans<="0101111";
			when others =>
				trans<="0000000";
		end case;

	end process;

--   000
--  1   2
--   333
--  4   5
--   666
	process(dx,dy,xpos,ypos,trans)
	begin
		dx <= xpos-lft;
		dy <= ypos-top;
		if(not((trans and "0000001")="0000000") and (dx>=0) and (dx<=20) and (dy<=4)) then
			draw <= true;
		elsif(not((trans and "0000010")="0000000") and (dx<=4) and (dy<=20)) then
			draw <= true;
		elsif(not((trans and "0000100")="0000000") and (dx>=16) and(dx<=20) and (dy<=20)) then
			draw <= true;
		elsif(not((trans and "0001000")="0000000") and (dx>=0) and (dx<=20) and (dy>=18) and (dy<=22)) then
			draw <= true;
		elsif(not((trans and "0010000")="0000000") and (dx<=4) and (dy>=20) and  (dy<=40)) then
			draw <= true;
		elsif(not((trans and "0100000")="0000000") and (dx>=16) and(dx<=20) and (dy>=20) and (dy<=40)) then
			draw <= true;
		elsif(not((trans and "1000000")="0000000") and (dx>=0) and (dx<=20) and (dy>=36) and (dy<=40)) then
			draw <= true;
		else
			draw <= false;
		end if;
	end process;

end architecture;
