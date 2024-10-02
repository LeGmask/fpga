LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY add4 IS
	PORT (
		X, Y : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		Cin  : IN  STD_LOGIC;
		S    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		Cout : OUT STD_LOGIC
	);
END add4;

ARCHITECTURE structural OF add4 IS

	COMPONENT add1
		PORT (
			X, Y, Cin : IN  STD_LOGIC;
			S, Cout   : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL c1, c2, c3 : STD_LOGIC;
BEGIN
	A1 : add1 PORT MAP(X(0), Y(0), Cin, S(0), c1);
	A2 : add1 PORT MAP(X(1), Y(1), c1, s(1), c2);
	A3 : add1 PORT MAP(X(2), Y(2), c2, s(2), c3);
	A4 : add1 PORT MAP(X(3), Y(3), c3, s(3), Cout);
END structural; -- structural
