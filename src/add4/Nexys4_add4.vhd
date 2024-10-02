LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4_add4 IS
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
END Nexys4_add4;

ARCHITECTURE synthesis OF Nexys4_add4 IS
	COMPONENT add4
		PORT (
			X, Y : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			Cin  : IN STD_LOGIC;
			S    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			Cout : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	-- convention afficheur 7 segments 0 => allumé, 1 => éteint
	ssg <= (OTHERS => '1');
	-- aucun afficheur sélectionné
	an(7 DOWNTO 0) <= (OTHERS => '1');
	-- 16 leds éteintes
	led(15 DOWNTO 5) <= (OTHERS => '0');

	-- connexion du (des) composant(s) avec les ports de la carte
	Inst_add4 : add4 PORT MAP(
		X    => swt(3 DOWNTO 0),
		Y    => swt(7 DOWNTO 4),
		Cin  => swt(8),
		S    => led(3 DOWNTO 0),
		Cout => led(4)
	);

END synthesis;
