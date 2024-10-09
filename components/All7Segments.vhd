LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY All7Segments IS
  PORT (
    clk   : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    e0    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e1    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e2    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e3    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e4    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e5    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e6    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    e7    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    an    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    ssg   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END All7Segments;

ARCHITECTURE structural OF All7Segments IS
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

  COMPONENT decalage IS
    -- v contient un seul '0' (utilisation : anode == segment allumé)
    -- à chaque front montant de l'horloge,
    -- la valeur de v est décalée cycliquement d'une position vers la gauche
    -- "11101111" -> "11011111"
    -- "01111111" -> "11111110"
    PORT (
      clk   : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      v     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT mux8_to_1 IS
    GENERIC (size : NATURAL := 4);
    PORT (
      e0, e1, e2, e3,
      e4, e5, e6, e7 : IN STD_LOGIC_VECTOR (size - 1 DOWNTO 0);
      sel            : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      s              : OUT STD_LOGIC_VECTOR (size - 1 DOWNTO 0));
  END COMPONENT;

  SIGNAL iclk   : STD_LOGIC;
  SIGNAL sel    : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL selVal : STD_LOGIC_VECTOR(3 DOWNTO 0);

  CONSTANT zero     : STD_LOGIC := '0';
  SIGNAL dummy_cout : STD_LOGIC;
BEGIN

  DivClk : diviseurClk
  GENERIC MAP(facteur => 100000)
  PORT MAP(clk => clk, reset => reset, nclk => iclk);

  Cpt : compteur
  GENERIC MAP(
    N => 3
  )
  PORT MAP(
    clk   => iclk,
    reset => reset,
    cpt   => sel,
    carry => dummy_cout
  );

  Mux : mux8_to_1
  GENERIC MAP(
    size => 4
  )
  PORT MAP(
    e0  => e0,
    e1  => e1,
    e2  => e2,
    e3  => e3,
    e4  => e4,
    e5  => e5,
    e6  => e6,
    e7  => e7,
    sel => sel,
    s   => selVal
  );

  Deca : decalage
  PORT MAP(
    clk   => iclk,
    reset => reset,
    v     => an
  );

  dec7seg_inst : dec7seg
  PORT MAP(
    v   => selVal,
    dot => zero,
    seg => ssg
  );
END structural;
