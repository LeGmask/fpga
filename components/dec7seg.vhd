LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY dec7seg IS
	PORT (
		v   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		dot : IN STD_LOGIC;
		seg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END dec7seg;

ARCHITECTURE synthesis OF dec7seg IS

	SIGNAL s : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN

	--  s <= "00111111" when value =  0 else
	--       "00000110" when value =  1 else
	--       "01011011" when value =  2 else
	--       "01001111" when value =  3 else
	--       "01100110" when value =  4 else
	--       "01101101" when value =  5 else
	--       "01111101" when value =  6 else
	--       "00000111" when value =  7 else
	--       "01111111" when value =  8 else
	--       "01101111" when value =  9 else
	--       "01110111" when value = 10 else
	--       "01111100" when value = 11 else
	--       "00111001" when value = 12 else
	--       "01011110" when value = 13 else
	--       "01111001" when value = 14 else
	--       "01110001";

	s(7) <= dot;

	s(6) <= (v(1) AND (v(3) OR NOT v(2) OR NOT v(0))) OR
	(v(3) AND v(0)) OR
	(NOT v(1) AND (v(3) XOR v(2)));

	s(5) <= (v(3) AND NOT v(2)) OR
	NOT(v(1) OR v(0)) OR
	(NOT v(1) AND (v(3) XOR v(2))) OR
	(v(3) AND v(1)) OR
	(v(2) AND NOT v(0));

	s(4) <= NOT(v(2) OR v(0)) OR
	(v(1) AND NOT v(0)) OR
	(v(3) AND (v(2) OR v(1)));

	s(3) <= (v(3) AND NOT v(1)) OR
	NOT(v(3) OR v(2) OR v(0)) OR
	(v(2) AND (v(1) XOR v(0))) OR
	(NOT v(2) AND v(1) AND v(0));

	s(2) <= (v(3) XOR v(2)) OR
	(NOT v(1) AND v(0)) OR
	(NOT(v(1) XOR v(0)) AND NOT v(2));

	s(1) <= NOT(v(3) OR v(2)) OR
	NOT(v(2) OR v(1)) OR
	NOT(v(2) OR v(0)) OR
	(NOT v(3) AND NOT(v(1) XOR v(0))) OR
	(v(3) AND NOT v(1) AND v(0));

	s(0) <= (NOT v(3) AND v(1)) OR
	(v(3) AND NOT v(0)) OR
	(v(2) AND v(1)) OR
	NOT (v(2) OR v(0)) OR
	(v(3) AND NOT v(2) AND NOT v(1)) OR
	(NOT v(3) AND v(2) AND v(0));

	seg <= NOT s;

END synthesis;
