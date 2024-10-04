LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4_compteur IS
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
END Nexys4_compteur;

ARCHITECTURE synthesis OF Nexys4_compteur IS
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

	COMPONENT compteur
		GENERIC (
			N : NATURAL
		);
		PORT (
			clk   : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			cpt   : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			carry : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT dec7seg
		PORT (
			v   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			dot : IN STD_LOGIC;
			seg : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL clk       : STD_LOGIC;
	SIGNAL cpt_out   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL carry_out : STD_LOGIC;
	SIGNAL reset     : STD_LOGIC;
BEGIN
	reset <= NOT btnC;

	-- convention afficheur 7 segments 0 => allumé, 1 => éteint
	-- ssg <= (others => '1');
	-- 1 afficheur sélectionné
	an(7 DOWNTO 0) <= (0 => '0', OTHERS => '1');
	-- 16 leds éteintes
	led(15 DOWNTO 1) <= (OTHERS => '0');

	-- connexion du (des) composant(s) avec les ports de la carte
	Inst_diviseurClk : diviseurClk GENERIC MAP(facteur => 100000000)
	PORT MAP(
		clk   => mclk,
		reset => reset,
		nclk  => clk
	);

	Inst_compteur : compteur GENERIC MAP(N => 4)
	PORT MAP(
		clk   => clk,
		reset => NOT btnC,
		cpt   => cpt_out,
		carry => carry_out
	);

	Inst_dec7seg : dec7seg PORT MAP(
		v   => cpt_out,
		dot => carry_out,
		seg => ssg
	);

	led(0) <= carry_out;
END synthesis;
