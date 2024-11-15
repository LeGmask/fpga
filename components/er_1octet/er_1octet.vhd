LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY er_1octet IS
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
END er_1octet;

ARCHITECTURE behavioral OF er_1octet IS
	-- The state of the FSM
	TYPE t_etat IS (idle, rec_bit, send_bit);
	-- The signal tracking the state of the FSM
	SIGNAL etat : t_etat;
BEGIN
	PROCESS (clk, rst)
		-- The counter of the current bit
		VARIABLE cpt_bit : NATURAL;

		-- The register to store the data to send
		VARIABLE reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		IF (rst = '0') THEN
			-- We are in reset state
			-- Reset all signals
			busy <= '0';
			sclk <= '1';

		ELSIF rising_edge(clk) THEN
			CASE etat IS
				WHEN idle =>
					IF (en = '1') THEN
						-- Waking up, 
						busy <= '1';
						sclk <= '0';

						-- Saving the data to send
						reg := din;

						cpt_bit := 7;
						-- Setting MOSI to the first bit
						mosi <= reg(cpt_bit);
						etat <= rec_bit;
					END IF;

				WHEN rec_bit =>
					-- We are mocking the clock
					-- As we are in rec_bit, so we are in a rising edge
					sclk <= '1';

					IF (cpt_bit = 0) THEN
						-- We have received all the bits
						busy <= '0';
						reg(cpt_bit) := miso;
						dout <= reg;
						etat <= idle;
					ELSE
						-- Receiving the current bit
						reg(cpt_bit) := miso;
						etat <= send_bit;
					END IF;

				WHEN send_bit =>
					-- We are mocking the clock
					-- As we are in send_bit, so we are in a falling edge
					sclk <= '0';

					-- The current cpt_bit is already sen
					-- We are sending the next bit
					cpt_bit := cpt_bit - 1;
					mosi <= reg(cpt_bit);
					etat <= rec_bit;
			END CASE;
		END IF;
	END PROCESS;
END behavioral;
