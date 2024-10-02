LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4_add1 IS
	PORT (
		-- les 16 switchs
		swt : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		-- les 5 boutons noirs
		btnC, btnU, btnL, btnR, btnD : IN STD_LOGIC;
		-- horloge
		mclk : IN STD_LOGIC;
		-- les 16 leds
		led : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		-- les anodes pour sélectionner les afficheurs 7 segments à utiliser
		an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		-- valeur affichée sur les 7 segments (point décimal compris, segment 7)
		ssg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END Nexys4_add1;

ARCHITECTURE synthesis OF Nexys4_add1 IS
	COMPONENT add1
		PORT (
			X, Y, Cin : IN STD_LOGIC;
			S, Cout   : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	-- convention afficheur 7 segments 0 => allumé, 1 => éteint
	ssg <= (OTHERS => '1');
	-- aucun afficheur sélectionné
	an(7 DOWNTO 0) <= (OTHERS => '1');
	-- 16 leds éteintes
	led(15 DOWNTO 2) <= (OTHERS => '0');

	-- connexion du (des) composant(s) avec les ports de la carte
	-- À COMPLÉTER 

	Inst_add1 : add1 PORT MAP(
		X    => swt(0),
		Y    => swt(1),
		Cin  => swt(2),
		S    => led(0),
		Cout => led(1)
	);

END synthesis;
