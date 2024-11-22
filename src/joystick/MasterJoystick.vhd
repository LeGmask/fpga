LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MasterJoystick IS
	PORT (
		rst     : IN STD_LOGIC;
		clk     : IN STD_LOGIC;
		en      : IN STD_LOGIC;
		inLed1  : IN STD_LOGIC;
		inLed2  : IN STD_LOGIC;
		miso    : IN STD_LOGIC;
		ss      : OUT STD_LOGIC;
		sclk    : OUT STD_LOGIC;
		mosi    : OUT STD_LOGIC;
		x_joy   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		y_joy   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		btn_joy : OUT STD_LOGIC;
		btn_1   : OUT STD_LOGIC;
		btn_2   : OUT STD_LOGIC;
		busy    : OUT STD_LOGIC);
END MasterJoystick;

ARCHITECTURE behavior OF MasterJoystick IS
	-- The state of the FSM
	TYPE t_state IS (idle, sync, exchange, exchange_wait);
	-- The signal tracking the state of the FSM
	SIGNAL state : t_state;

	COMPONENT diviseurClk IS
		-- facteur : ratio entre la fréquence de l'horloge origine et celle
		--           de l'horloge générée
		--  ex : 100 MHz -> 1Hz : 100 000 000
		--  ex : 100 MHz -> 1kHz : 100 000
		GENERIC (facteur : NATURAL);
		PORT (
			clk, reset : IN STD_LOGIC;
			nclk       : OUT STD_LOGIC);
	END COMPONENT;

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

	SIGNAL nclk : STD_LOGIC; -- divided clock

	SIGNAL reg_inLed     : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reg_x_joy_low : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reg_y_joy_low : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL din    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dout   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL enER   : STD_LOGIC;
	SIGNAL busyER : STD_LOGIC;
BEGIN

	diviseurClk_inst : diviseurClk GENERIC MAP(facteur => 100)
	PORT MAP(
		clk   => clk,
		reset => rst,
		nclk  => nclk
	);

	er_1octet_inst : er_1octet
	PORT MAP(
		rst  => rst,
		clk  => nclk,
		en   => enER,
		din  => din,
		miso => miso,
		sclk => sclk,
		mosi => mosi,
		dout => dout,
		busy => busyER
	);

	PROCESS (nclk, rst)
		-- Variable used to count the number of clock cycles
		VARIABLE tick_count : NATURAL := 0;
		-- Variable to know which message we are sending
		VARIABLE exchange_count : NATURAL := 0;
		-- Variable to know if we are sending the last message
		VARIABLE isLast : BOOLEAN := false;
		-- Variable to know if we are sending a message
		VARIABLE sending : BOOLEAN := false;
	BEGIN
		IF (rst = '0') THEN
			-- We are in reset state
			-- Reset all signals
			tick_count     := 0;
			exchange_count := 0;
			isLast         := false;

			enER  <= '0';
			busy  <= '0';
			ss    <= '1';
			state <= idle;
		ELSIF rising_edge(nclk) THEN
			CASE state IS
				WHEN idle =>
					IF (en = '1') THEN
						-- Waking up, 
						tick_count := 0;
						busy <= '1';
						ss   <= '0';

						-- Waiting for synchronization
						state <= sync;

						-- We store the input data in a register
						reg_inLed <= "100000" & inLed1 & inLed2;
					END IF;

				WHEN sync =>
					-- This is the synchronization state
					-- We are waiting for 10 clock cycles
					tick_count := tick_count + 1;
					IF tick_count >= 10 THEN
						tick_count := 0;
						state <= exchange;
					END IF;

				WHEN exchange =>
					CASE exchange_count IS
							-- For each exchange, we are sending a message,
							-- First we are activating the er_1octet component by setting enER to '1'
							-- On the next clock cycle, we are deactivating the er_1octet component by setting enER to '0'
							-- This is used in order to avoid sending multiple messages next to each other
							-- Once we are done with the exchange (enBusy = '0'), we are saving the value of the received message
							-- Then we go to the exchange_wait state to wait for 3 clock cycles before sending the next message
						WHEN 0 =>
							IF (NOT sending) AND enER = '0' AND busyER = '0' THEN
								-- The first message is the inLed, so we send the inLed register
								din  <= reg_inLed;
								enER <= '1';
								sending := true;
							ELSIF sending AND enER = '1' AND busyER = '0' THEN
								enER <= '0';
							ELSIF sending AND enER = '0' AND busyER = '0' THEN
								sending := false;

								-- The first message is the x_joy_low, so we store it
								-- in a register in order to concatenate it with the
								-- x_joy_high.
								reg_x_joy_low <= dout;
								state         <= exchange_wait;
							END IF;

						WHEN 1 =>
							-- The second message is the x_joy_high, at the end
							-- we concatenate it with the x_joy_low with the output
							-- we do nothing in input
							IF (NOT sending) AND enER = '0' AND busyER = '0' THEN
								din  <= "00000000";
								enER <= '1';
								sending := true;
							ELSIF sending AND enER = '1' AND busyER = '0' THEN
								enER <= '0';
							ELSIF sending AND enER = '0' AND busyER = '0' THEN
								sending := false;

								x_joy <= dout(1 DOWNTO 0) & reg_x_joy_low;
								state <= exchange_wait;
							END IF;

						WHEN 2 =>
							-- The third message is the y_joy_low, we store
							-- it in a register in order to concatenate it with
							-- the y_joy_high.
							-- We do nothing in input
							IF (NOT sending) AND enER = '0' AND busyER = '0' THEN
								din  <= "00000000";
								enER <= '1';
								sending := true;
							ELSIF sending AND enER = '1' AND busyER = '0' THEN
								enER <= '0';
							ELSIF sending AND enER = '0' AND busyER = '0' THEN
								sending := false;

								reg_y_joy_low <= dout;
								state         <= exchange_wait;
							END IF;

						WHEN 3 =>
							-- The fourth message is the y_joy_high, at the end
							-- we concatenate it with the y_joy_low with the output
							-- we do nothing in input
							IF (NOT sending) AND enER = '0' AND busyER = '0' THEN
								din  <= "00000000";
								enER <= '1';
								sending := true;
							ELSIF sending AND enER = '1' AND busyER = '0' THEN
								enER <= '0';
							ELSIF sending AND enER = '0' AND busyER = '0' THEN
								sending := false;

								y_joy <= dout(1 DOWNTO 0) & reg_y_joy_low;
								state <= exchange_wait;
							END IF;

						WHEN 4 =>
							-- The fifth message is the state of the buttons,
							-- we split it in the 3 buttons. and set the output
							-- signals that correspond to the buttons.
							-- 							
							IF (NOT sending) AND enER = '0' AND busyER = '0' THEN
								din  <= "00000000";
								enER <= '1';
								sending := true;
							ELSIF sending AND enER = '1' AND busyER = '0' THEN
								enER <= '0';
							ELSIF sending AND enER = '0' AND busyER = '0' THEN
								sending := false;

								btn_2   <= dout(2);
								btn_1   <= dout(1);
								btn_joy <= dout(0);

								isLast := true;
								state <= exchange_wait;
							END IF;

						WHEN OTHERS => NULL;
					END CASE;

				WHEN exchange_wait =>
					-- We are waiting for 3 clock cycles between each exchange
					tick_count := tick_count + 1;
					IF tick_count >= 3 THEN
						tick_count     := 0;
						exchange_count := exchange_count + 1;

						IF isLast THEN
							-- We are done with the exchange
							-- Reset all signals and variables
							exchange_count := 0;
							isLast         := false;

							busy  <= '0';
							ss    <= '1';
							state <= idle;
						ELSE
							-- Do another exchange
							state <= exchange;
						END IF;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END behavior;
