LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY compteur IS
	GENERIC (
		N : INTEGER := 4
	);

	PORT (
		clk   : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		cpt   : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		carry : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE behavioral OF compteur IS
	SIGNAL cpt_aux : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
	carry <= '1' WHEN cpt_aux = 0 AND reset = '1' ELSE
		'0';
	cpt <= cpt_aux;

	PROCESS (clk, reset)
	BEGIN
		IF (reset = '0') THEN
			cpt_aux <= (OTHERS => '0');
		ELSIF (rising_edge(clk)) THEN
			cpt_aux <= cpt_aux + 1;
		END IF;
	END PROCESS;
END ARCHITECTURE;
