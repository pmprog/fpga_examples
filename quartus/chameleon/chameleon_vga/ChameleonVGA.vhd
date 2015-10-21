
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity ChameleonVGA is
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
--		usart_tx : in std_logic;
--		usart_clk : in std_logic;
--		usart_rts : in std_logic;
--		usart_cts : in std_logic;

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


architecture rtl of ChameleonVGA is
	type state_t is (TEST_IDLE, TEST_FILL, TEST_FILL_W, TEST_CHECK, TEST_CHECK_W, TEST_ERROR);
	
-- System clocks
	signal sysclk : std_logic;
	signal clk_150 : std_logic;
	signal sd_clk_loc : std_logic;
	signal clk_locked : std_logic;
	signal ena_1mhz : std_logic;
	signal ena_1khz : std_logic;
	signal no_clock : std_logic;

	signal reset_button_n : std_logic;
	
-- Global signals
	signal reset : std_logic;
	signal end_of_pixel : std_logic;
	signal end_of_frame : std_logic;
	
-- MUX
	signal mux_clk_reg : std_logic := '0';
	signal mux_reg : unsigned(3 downto 0) := (others => '1');
	signal mux_d_reg : unsigned(3 downto 0) := (others => '1');

-- 4 Port joystick adapter
	signal video_joystick_shift_reg : std_logic;

-- C64 keyboard (on joystick adapter)
	signal video_keyboard_reg : std_logic;
	
-- LEDs
	signal led_green : std_logic;
	signal led_red : std_logic;

-- PS/2 Keyboard
	signal ps2_keyboard_clk_in : std_logic;
	signal ps2_keyboard_dat_in : std_logic;
	signal ps2_keyboard_clk_out : std_logic;
	signal ps2_keyboard_dat_out : std_logic;

	signal keyboard_trigger : std_logic;
	signal keyboard_scancode : unsigned(7 downto 0);

-- SDram	
	signal sdram_req : std_logic := '0';
	signal sdram_ack : std_logic;
	signal sdram_we : std_logic := '0';
	signal sdram_a : unsigned(24 downto 0) := (others => '0');
	signal sdram_d : unsigned(7 downto 0);
	signal sdram_q : unsigned(7 downto 0);

-- VGA
	signal currentX : unsigned(11 downto 0);
	signal currentY : unsigned(11 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;
	
-- Sound
	signal sigma_l_reg : std_logic := '0';
	signal sigma_r_reg : std_logic := '0';

-- Docking station
	signal docking_station : std_logic;
	signal docking_keys : unsigned(63 downto 0);
	signal docking_restore_n : std_logic;
	signal docking_irq : std_logic;
	signal irq_n : std_logic;
	
	signal docking_joystick1 : unsigned(5 downto 0);
	signal docking_joystick2 : unsigned(5 downto 0);
	signal docking_joystick3 : unsigned(5 downto 0);
	signal docking_joystick4 : unsigned(5 downto 0);

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
-- Phi 2
-- -----------------------------------------------------------------------
	myPhi2: entity work.chameleon_phi_clock
		port map (
			clk => sysclk,
			phi2_n => phi2_n,
		
			-- no_clock is high when there are no phiIn changes detected.
			-- This signal allows switching between real I/O and internal emulation.
			no_clock => no_clock,
		
			-- docking_station is high when there are no phiIn changes (no_clock) and
			-- the phi signal is low. Without docking station phi is pulled up.
			docking_station => docking_station
		);

-- -----------------------------------------------------------------------
-- Reset
-- -----------------------------------------------------------------------
	myReset : entity work.gen_reset
		generic map (
			resetCycles => resetCycles
		)
		port map (
			clk => sysclk,
			enable => '1',

			button => '0',
			reset => reset
		);

-- -----------------------------------------------------------------------
-- 1 Mhz and 1 Khz clocks
-- -----------------------------------------------------------------------
	my1Mhz : entity work.chameleon_1mhz
		generic map (
			clk_ticks_per_usec => 100
		)
		port map (
			clk => sysclk,
			ena_1mhz => ena_1mhz,
			ena_1mhz_2 => open
		);

	my1Khz : entity work.chameleon_1khz
		port map (
			clk => sysclk,
			ena_1mhz => ena_1mhz,
			ena_1khz => ena_1khz
		);
	

-- -----------------------------------------------------------------------
-- SDRAM Controller
-- -----------------------------------------------------------------------
	sdramInstance : entity work.chameleon_sdram
		generic map (
			casLatency => 3,
			colAddrBits => 9,
			rowAddrBits => 13,
			enable_cpu6510_port => true
		)
		port map (
			clk => clk_150,

			reserve => '0',

			sd_data => sd_data,
			sd_addr => sd_addr,
			sd_we_n => sd_we_n,
			sd_ras_n => sd_ras_n,
			sd_cas_n => sd_cas_n,
			sd_ba_0 => sd_ba_0,
			sd_ba_1 => sd_ba_1,
			sd_ldqm => sd_ldqm,
			sd_udqm => sd_udqm,
			
			cpu6510_req => sdram_req,
			cpu6510_ack => sdram_ack,
			cpu6510_we => sdram_we,
			cpu6510_a => sdram_a,
			cpu6510_d => sdram_d,
			cpu6510_q => sdram_q,

			debugIdle => open,
			debugRefresh => open
		);
		
-- -----------------------------------------------------------------------
-- Docking station
-- -----------------------------------------------------------------------
	myDockingStation : entity work.chameleon_docking_station
		port map (
			clk => sysclk,
			
			docking_station => docking_station,
			
			dotclock_n => dotclock_n,
			io_ef_n => ioef_n,
			rom_lh_n => romlh_n,
			irq_q => docking_irq,
			
			joystick1 => docking_joystick1,
			joystick2 => docking_joystick2,
			joystick3 => docking_joystick3,
			joystick4 => docking_joystick4,
			keys => docking_keys,
			restore_key_n => docking_restore_n,
			
			amiga_power_led => '0',
			amiga_drive_led => '0'
			
		);
	
	-- -----------------------------------------------------------------------
-- MUX CPLD
-- -----------------------------------------------------------------------
	-- MUX clock
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			mux_clk_reg <= not mux_clk_reg;
		end if;
	end process;

	-- MUX read
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			if mux_clk_reg = '1' then
				case mux_reg is
				when X"6" =>
					irq_n <= mux_q(2);
				when X"B" =>
					reset_button_n <= mux_q(1);
				when X"A" =>
					vga_id <= mux_q;
				when X"E" =>
					ps2_keyboard_dat_in <= mux_q(0);
					ps2_keyboard_clk_in <= mux_q(1);
				when others =>
					null;
				end case;
			end if;
		end if;
	end process;

	-- MUX write
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			if mux_clk_reg = '1' then
				case mux_reg is
				when X"7" =>
					mux_d_reg <= "1111";
					if docking_station = '1' then
						mux_d_reg <= "1" & docking_irq & "11";
					end if;
					mux_reg <= X"6";
				when X"6" =>
					mux_d_reg <= "1111";
					mux_reg <= X"8";
				when X"8" =>
					mux_d_reg <= "1111";
					mux_reg <= X"A";
				when X"A" =>
					mux_d_reg <= "10" & led_green & led_red;
					mux_reg <= X"B";
				when X"B" =>
					mux_reg <= X"D";
				when X"D" =>
					mux_d_reg(0) <= ps2_keyboard_dat_out;
					mux_d_reg(1) <= ps2_keyboard_clk_out;
					mux_reg <= X"E";
				when X"E" =>
					mux_d_reg <= "1111";
					mux_reg <= X"7";
				when others =>
					mux_reg <= X"B";
					mux_d_reg <= "10" & led_green & led_red;
				end case;
			end if;
		end if;
	end process;
	
	mux_clk <= mux_clk_reg;
	mux_d <= mux_d_reg;
	mux <= mux_reg;

-- -----------------------------------------------------------------------
-- LEDs
-- -----------------------------------------------------------------------
	myGreenLed : entity work.chameleon_led
		port map (
			clk => sysclk,
			clk_1khz => ena_1khz,
			led_on => '0',
			led_blink => '1',
			led => led_red,
			led_1hz => led_green
		);

-- -----------------------------------------------------------------------
-- Keyboard controller
-- -----------------------------------------------------------------------
	myKeyboard : entity work.io_ps2_keyboard
		generic map (
			ticksPerUsec => 100
		)
		port map (
			clk => sysclk,
			reset => reset,
			
			ps2_clk_in => ps2_keyboard_clk_in,
			ps2_dat_in => ps2_keyboard_dat_in,
			ps2_clk_out => ps2_keyboard_clk_out,
			ps2_dat_out => ps2_keyboard_dat_out,
			
			-- Flash caps and num lock LEDs
			caps_lock => led_green,
			num_lock => led_red,
			scroll_lock => '0',

			trigger => keyboard_trigger,
			scancode => keyboard_scancode
		);

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
