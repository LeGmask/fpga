LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decalage IS
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
END decalage;

ARCHITECTURE behavorial OF decalage IS

BEGIN

  PROCESS (clk, reset)

    VARIABLE v_aux : STD_LOGIC_VECTOR (7 DOWNTO 0);

  BEGIN

    IF (reset = '0') THEN
      -- v_aux := (0 => '1', others => '0');
      v_aux := (0 => '0', OTHERS => '1');
      v <= v_aux;
    ELSIF (rising_edge(clk)) THEN
      v_aux := v_aux(6 DOWNTO 0) & v_aux(7);
      v <= v_aux;
    END IF;

  END PROCESS;

END behavorial;
