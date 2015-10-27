
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity chameleon_vga is
	generic (
		resetCycles: integer := 131071
	);
	port (
-- Clocks
		clk8 : in std_logic;
		phi2_n : in std_logic;
		dotclock_n : in std_logic;

-- Bus
		romlh_n : in std_logic;
		ioef_n : in std_logic;

-- Buttons
		freeze_n : in std_logic;

-- MMC/SPI
		spi_miso : in std_logic;
		mmc_cd_n : in std_logic;
		mmc_wp : in std_logic;

-- MUX CPLD
		mux_clk : out std_logic;
		mux : out unsigned(3 downto 0);
		mux_d : out unsigned(3 downto 0);
		mux_q : in unsigned(3 downto 0);

-- USART
		usart_tx : in std_logic;
		usart_clk : in std_logic;
		usart_rts : in std_logic;
		usart_cts : in std_logic;

-- SDRam
		sd_clk : out std_logic;
		sd_data : inout unsigned(15 downto 0);
		sd_addr : out unsigned(12 downto 0);
		sd_we_n : out std_logic;
		sd_ras_n : out std_logic;
		sd_cas_n : out std_logic;
		sd_ba_0 : out std_logic;
		sd_ba_1 : out std_logic;
		sd_ldqm : out std_logic;
		sd_udqm : out std_logic;

-- Video
		red : out unsigned(4 downto 0);
		grn : out unsigned(4 downto 0);
		blu : out unsigned(4 downto 0);
		nHSync : out std_logic;
		nVSync : out std_logic;
		vga_id : out unsigned(3 downto 0);

-- Audio
		sigmaL : out std_logic;
		sigmaR : out std_logic
	);
end entity;


architecture rtl of chameleon_vga is
	
-- System clocks
	signal sysclk : std_logic;
	signal clk_150 : std_logic;
	signal sd_clk_loc : std_logic;
	signal clk_locked : std_logic;

-- VGA
	signal end_of_pixel : std_logic;
	signal end_of_frame : std_logic;
	signal currentX : unsigned(11 downto 0);
	signal currentY : unsigned(11 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;

begin
	nHSync <= not hsync;
	nVSync <= not vsync;
	
-- -----------------------------------------------------------------------
-- Clocks and PLL
-- -----------------------------------------------------------------------
	pllInstance : entity work.pll8
		port map (
			inclk0 => clk8,
			c0 => sysclk,
			c1 => open, 
			c2 => clk_150,
			c3 => sd_clk_loc,
			locked => clk_locked
		);
	sd_clk <= sd_clk_loc;

-- -----------------------------------------------------------------------
-- VGA timing configured for 640x480
-- -----------------------------------------------------------------------
	myVgaMaster : entity work.video_vga_master
		generic map (
			clkDivBits => 4
		)
		port map (
			clk => sysclk,
			-- 100 Mhz / (3+1) = 25 Mhz
			clkDiv => X"3",

			hSync => hSync,
			vSync => vSync,

			endOfPixel => end_of_pixel,
			endOfLine => open,
			endOfFrame => end_of_frame,
			currentX => currentX,
			currentY => currentY,

			-- Setup 640x480@60hz needs ~25 Mhz
			hSyncPol => '0',
			vSyncPol => '0',
			xSize => to_unsigned(800, 12),
			ySize => to_unsigned(525, 12),
			xSyncFr => to_unsigned(656, 12), -- Sync pulse 96
			xSyncTo => to_unsigned(752, 12),
			ySyncFr => to_unsigned(500, 12), -- Sync pulse 2
			ySyncTo => to_unsigned(502, 12)
		);
		
-- -----------------------------------------------------------------------
-- VGA colors
-- -----------------------------------------------------------------------
	process(sysclk)
		variable x : signed(11 downto 0);
		variable y : signed(11 downto 0);
	begin
		x := signed(currentX);
		y := signed(currentY);
		if rising_edge(sysclk) then
			if end_of_pixel = '1' then
				red <= (others => '0');
				grn <= (others => '0');
				blu <= (others => '0');
				if currentY < 256 then
					case currentX(11 downto 7) is
					when "00001" =>
						red <= currentX(6 downto 2);
					when "00010" =>
						grn <= currentX(6 downto 2);
					when "00011" =>
						blu <= currentX(6 downto 2);
					when "00100" =>
						red <= currentX(6 downto 2);
						grn <= currentX(6 downto 2);
						blu <= currentX(6 downto 2);
					when others =>
						null;
					end case;
				end if;
				
			-- One pixel border around the screen
				if (currentX = 0) or (currentX = 639) or (currentY =0) or (currentY = 479) then
					red <= (others => '1');
					grn <= (others => '1');
					blu <= (others => '1');
				end if;

			-- Never draw pixels outside the visual area
				if (currentX >= 640) or (currentY >= 480) then
					red <= (others => '0');
					grn <= (others => '0');
					blu <= (others => '0');
				end if;
			end if;
		end if;
	end process;

end architecture;
