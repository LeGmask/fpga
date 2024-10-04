LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY test_diviseurClk IS
END ENTITY;

ARCHITECTURE behavior OF test_diviseurClk IS
	COMPONENT diviseurClk IS
		-- facteur : ratio entre la fréquence de l'horloge origine à 100 MHz
		--           et celle de l'horloge générée
		--  ex : 100 MHz -> 1Hz : facteur = 100 000 000
		--  ex : 100 MHz -> 1kHz : facteur = 100 000 
		GENERIC (facteur : NATURAL);
		PORT (
			clk, reset : IN STD_LOGIC;
			nclk       : OUT STD_LOGIC);
	END COMPONENT;

	--Inputs
	SIGNAL clk   : STD_LOGIC := '0';
	SIGNAL reset : STD_LOGIC := '0';

	--Outputs
	SIGNAL nclk : STD_LOGIC;

	-- Clock period definitions
	CONSTANT clk_period : TIME := 10 ns;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : diviseurClk GENERIC MAP(facteur => 10)
	PORT MAP(
		clk   => clk,
		reset => reset,
		nclk  => nclk
	);

	-- Clock process definitions
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		-- hold reset state for 100 ns.
		WAIT FOR 100 ns;
		reset <= '0';
		WAIT FOR clk_period * 10;

		reset <= '1';

		WAIT;
	END PROCESS;

END ARCHITECTURE;
