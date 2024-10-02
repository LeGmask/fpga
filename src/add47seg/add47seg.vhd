library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity add47seg is
  port (
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0)
  );
end add47seg;

architecture synthesis of add47seg is
  component add4
    port (
      X, Y  : in std_logic_vector (3 downto 0);
      Cin   : in std_logic;
      S     : out std_logic_vector (3 downto 0);
      Cout  : out std_logic
    );
  end component;

  COMPONENT dec7seg
	PORT(
		v : IN std_logic_vector(3 downto 0);     
    dot : in std_logic;     
		seg : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

  signal sum: std_logic_vector (3 downto 0);
  signal cout_dot: std_logic;
begin
  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  -- ssg <= (others => '1');
  -- 1 afficheur sélectionné
  an(7 downto 0) <= (0 => '0', others => '1');
  -- 16 leds éteintes
  led(15 downto 0) <= (others => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  Inst_add4: add4 port map (
    X => swt(3 downto 0),
    Y => swt(7 downto 4),
    Cin => swt(8),
    S => sum,
    Cout => cout_dot
  );

  Inst_dec7seg: dec7seg PORT MAP(
		v => sum,
    dot => cout_dot,
		seg => ssg
	);

end synthesis;
