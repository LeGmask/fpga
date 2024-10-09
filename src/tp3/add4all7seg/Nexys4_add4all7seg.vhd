LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4_add4all7seg IS
  PORT (
    -- les 16 switchs
    swt : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- les anodes pour sélectionner l'afficheur 7 segments
    an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- afficheur 7 segments (point décimal compris, segment 7)
    ssg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- horloge
    mclk : IN STD_LOGIC;
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : IN STD_LOGIC;
    -- les 16 leds
    led : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END Nexys4_add4all7seg;

ARCHITECTURE synthesis OF Nexys4_add4all7seg IS

  -- rappel du (des) composant(s)
  COMPONENT all7segments
    PORT (
      clk   : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      e0    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e1    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e2    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e3    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e4    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e5    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e6    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      e7    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      an    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      ssg   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT add4
    PORT (
      X, Y : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      Cin  : IN STD_LOGIC;
      S    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      Cout : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL carry_in, carry_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL sum                 : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL carry               : STD_LOGIC;
  SIGNAL reset               : STD_LOGIC;

  -- FOR Inst_All7Segments : All7Segments USE ENTITY work.All7Segments(structural);

BEGIN

  -- valeurs des sorties

  -- 16 leds éteintes
  led(15 DOWNTO 0) <= (OTHERS => '0');

  carry_in  <= "000" & swt(8);
  carry_out <= "000" & carry;

  reset <= NOT btnC;

  -- connexion du (des) composant(s) avec les ports de la carte

  -- À compléter/connecter
  Inst_All7Segments : All7Segments
  PORT MAP(
    clk   => mclk,
    reset => reset,
    e0    => swt(3 DOWNTO 0),
    e1    => swt(7 DOWNTO 4),
    e2    => carry_in,
    e3    => sum,
    e4    => carry_out,
    e5    => "0000",
    e6    => "0000",
    e7    => "0000",
    an    => an,
    ssg   => ssg
  );

  -- déjà connecté
  Inst_add4 : add4
  PORT MAP(
    X    => swt(3 DOWNTO 0),
    Y    => swt(7 DOWNTO 4),
    Cin  => swt(8),
    S    => sum,
    Cout => carry
  );
END synthesis;
