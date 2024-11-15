LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY TestOpl IS
END TestOpl;

ARCHITECTURE behavior OF TestOpl IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT MasterOpl
		PORT (
			rst     : IN STD_LOGIC;
			clk     : IN STD_LOGIC;
			en      : IN STD_LOGIC;
			v1      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			v2      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			miso    : IN STD_LOGIC;
			ss      : OUT STD_LOGIC;
			sclk    : OUT STD_LOGIC;
			mosi    : OUT STD_LOGIC;
			val_xor : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			val_and : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			val_or  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			busy    : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT SlaveOpl IS
		PORT (
			sclk : IN STD_LOGIC;
			mosi : IN STD_LOGIC;
			miso : OUT STD_LOGIC;
			ss   : IN STD_LOGIC
		);
	END COMPONENT;

	--Inputs
	SIGNAL rst  : STD_LOGIC                    := '0';
	SIGNAL clk  : STD_LOGIC                    := '0';
	SIGNAL en   : STD_LOGIC                    := '0';
	SIGNAL v1   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL v2   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL miso : STD_LOGIC                    := '0';

	--Outputs
	SIGNAL ss      : STD_LOGIC;
	SIGNAL sclk    : STD_LOGIC;
	SIGNAL mosi    : STD_LOGIC;
	SIGNAL val_xor : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL val_and : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL val_or  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL busy    : STD_LOGIC;

	-- Clock period definitions
	CONSTANT clk_period  : TIME := 10 ns;
	CONSTANT sclk_period : TIME := 10 ns;

	-- types
	TYPE t_state IS (waiting, testCase, fin);

	-- signaux internes   
	SIGNAL state : t_state;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	Inst_MasterOpl : MasterOpl PORT MAP(
		rst     => rst,
		clk     => clk,
		en      => en,
		v1      => v1,
		v2      => v2,
		miso    => miso,
		ss      => ss,
		sclk    => sclk,
		mosi    => mosi,
		val_xor => val_xor,
		val_and => val_and,
		val_or  => val_or,
		busy    => busy
	);

	Inst_SlaveOpl : SlaveOpl PORT MAP(
		sclk => sclk,
		mosi => mosi,
		miso => miso,
		ss   => ss
	);

	-- Clock process definitions
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;

	rst <= '0', '1' AFTER 100 ns;
	-- state <= waiting;

	-- Stimulus process
	stim_proc : PROCESS (clk, rst)
		VARIABLE tick_count : NATURAL;
		VARIABLE sendCount  : NATURAL := 0;
		VARIABLE running    : BOOLEAN := false;
	BEGIN
		IF rst = '0' THEN
			tick_count := 0;
			sendCount  := 0;
			running    := false;
			en    <= '0';
			state <= waiting;
		ELSIF rising_edge(clk) THEN
			CASE state IS
				WHEN waiting =>
					tick_count := tick_count + 1;
					IF tick_count > 10 THEN
						-- en <= '1';
						tick_count := 0;
						state <= testCase;
					END IF;

				WHEN testCase =>
					CASE sendCount IS
						WHEN 0 =>
							IF (NOT running) AND en = '0' AND busy = '0' THEN
								en <= '1';
								running := true;
								v1 <= "00000000";
								v2 <= "11111111";
							ELSIF running AND en = '1' AND busy = '1' THEN
								-- On desactive pour eviter que le module
								-- recommence immédiatement un échange une fois
								-- finis.	
								en <= '0';
							ELSIF running AND en = '0' AND busy = '0' THEN
								running   := false;
								sendCount := sendCount + 1;
								state <= waiting;
							END IF;
						WHEN 1 =>
							IF (NOT running) AND en = '0' AND busy = '0' THEN
								en <= '1';
								running := true;
								v1 <= "11110000";
								v2 <= "00001111";
							ELSIF running AND en = '1' AND busy = '1' THEN
								-- On desactive pour eviter que le module
								-- recommence immédiatement un échange une fois
								-- finis.	
								en <= '0';
							ELSIF running AND en = '0' AND busy = '0' THEN
								running   := false;
								sendCount := sendCount + 1;
								state <= waiting;
							END IF;
						WHEN 2 =>
							IF (NOT running) AND en = '0' AND busy = '0' THEN
								en <= '1';
								running := true;
								v1 <= "11001100";
								v2 <= "11100111";
							ELSIF running AND en = '1' AND busy = '1' THEN
								-- On desactive pour eviter que le module
								-- recommence immédiatement un échange une fois
								-- finis.	
								en <= '0';
							ELSIF running AND en = '0' AND busy = '0' THEN
								running   := false;
								sendCount := sendCount + 1;
								state <= waiting;
							END IF;
						WHEN 3 =>

							IF (NOT running) AND en = '0' AND busy = '0' THEN
								running := true;
								en <= '1';
								v1 <= "10101010";
								v2 <= "11110000";
							ELSIF running AND en = '1' AND busy = '1' THEN
								-- On desactive pour eviter que le module
								-- recommence immédiatement un échange une fois
								-- finis.	
								en <= '0';
							ELSIF running AND en = '0' AND busy = '0' THEN
								running   := false;
								sendCount := sendCount + 1;
								state <= waiting;
							END IF;
						WHEN 4 =>
							IF (NOT running) AND en = '0' AND busy = '0' THEN
								en <= '1';
								running := true;
								v1 <= "00000000";
								v2 <= "00000000";
							ELSIF running AND en = '1' AND busy = '1' THEN
								-- On desactive pour eviter que le module
								-- recommence immédiatement un échange une fois
								-- finis.	
								en <= '0';
							ELSIF running AND en = '0' AND busy = '0' THEN
								running   := false;
								sendCount := sendCount + 1;
								state <= fin;
							END IF;
						WHEN OTHERS => state <= fin;
					END CASE;

				WHEN fin => NULL;
			END CASE;
		END IF;
		-- WAIT;
	END PROCESS;

END;
