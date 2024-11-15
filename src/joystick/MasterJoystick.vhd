LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MasterJoystick IS
	PORT (
		rst     : IN STD_LOGIC;
		clk     : IN STD_LOGIC;
		en      : IN STD_LOGIC;
		v1      : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		v2      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		miso    : IN STD_LOGIC;
		ss      : OUT STD_LOGIC;
		sclk    : OUT STD_LOGIC;
		mosi    : OUT STD_LOGIC;
		val_xor : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		val_and : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		val_or  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		busy    : OUT STD_LOGIC);
END MasterJoystick;

ARCHITECTURE behavior OF MasterJoystick IS
	TYPE t_state IS (idle, sync, exchange, exchange_wait);
	SIGNAL state : t_state;

	COMPONENT er_1octet
		PORT (
			rst  : IN STD_LOGIC;
			clk  : IN STD_LOGIC;
			en   : IN STD_LOGIC;
			din  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			miso : IN STD_LOGIC;
			sclk : OUT STD_LOGIC;
			mosi : OUT STD_LOGIC;
			dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			busy : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL din    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dout   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL enER   : STD_LOGIC;
	SIGNAL enBusy : STD_LOGIC;
BEGIN

	er_1octet_inst : er_1octet
	PORT MAP(
		rst  => rst,
		clk  => clk,
		en   => enER,
		din  => din,
		miso => miso,
		sclk => sclk,
		mosi => mosi,
		dout => dout,
		busy => enBusy
	);

	PROCESS (clk, rst)
		VARIABLE tick_count     : NATURAL := 0;
		VARIABLE exchange_count : NATURAL := 0;
		VARIABLE isLast         : BOOLEAN := false;
		VARIABLE sending        : BOOLEAN := false;
	BEGIN
		IF (rst = '0') THEN
			tick_count     := 0;
			exchange_count := 0;
			isLast         := false;

			enER  <= '0';
			busy  <= '0';
			ss    <= '1';
			state <= idle;
		ELSIF rising_edge(clk) THEN
			CASE state IS
				WHEN idle =>
					IF (en = '1') THEN
						tick_count := 0;
						busy  <= '1';
						ss    <= '0';
						state <= sync;
					END IF;

				WHEN sync =>
					tick_count := tick_count + 1;
					IF tick_count >= 10 THEN
						tick_count := 0;
						state <= exchange;
					END IF;

				WHEN exchange =>
					CASE exchange_count IS
						WHEN 0 =>
							IF sending = false AND enER = '0' AND enBusy = '0' THEN
								din  <= v1;
								enER <= '1';
								sending := true;
							ELSIF sending = true AND enER = '1' AND enBusy = '0' THEN
								enER <= '0';
							ELSIF sending = true AND enER = '0' AND enBusy = '0' THEN
								sending := false;
								val_xor <= dout;
								state   <= exchange_wait;
							END IF;

						WHEN 1 =>
							IF sending = false AND enER = '0' AND enBusy = '0' THEN
								din  <= v2;
								enER <= '1';
								sending := true;
							ELSIF sending = true AND enER = '1' AND enBusy = '0' THEN
								enER <= '0';
							ELSIF sending = true AND enER = '0' AND enBusy = '0' THEN
								sending := false;

								val_and <= dout;
								state   <= exchange_wait;
							END IF;

						WHEN 2 =>
							IF sending = false AND enER = '0' AND enBusy = '0' THEN
								din  <= "00000000";
								enER <= '1';
								sending := true;
							ELSIF sending = true AND enER = '1' AND enBusy = '0' THEN
								enER <= '0';
							ELSIF sending = true AND enER = '0' AND enBusy = '0' THEN
								sending := false;
								val_or <= dout;

								isLast := true;
								state <= exchange_wait;
							END IF;

						WHEN OTHERS => NULL;
					END CASE;

				WHEN exchange_wait =>
					tick_count := tick_count + 1;
					IF tick_count >= 3 THEN
						tick_count     := 0;
						exchange_count := exchange_count + 1;

						IF isLast THEN
							-- On resets les différents état 
							-- on a fini d'échanger notre message
							exchange_count := 0;
							isLast         := false;

							busy  <= '0';
							ss    <= '1';
							state <= idle;
						ELSE
							state <= exchange;
						END IF;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END behavior;
