LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY diviseurClk IS
  -- facteur : ratio entre la fréquence de l'horloge origine à 100 MHz
  --           et celle de l'horloge générée
  --  ex : 100 MHz -> 1Hz : facteur = 100 000 000
  --  ex : 100 MHz -> 1kHz : facteur = 100 000 
  GENERIC (facteur : NATURAL);
  PORT (
    clk, reset : IN STD_LOGIC;
    nclk       : OUT STD_LOGIC);
END diviseurClk;

ARCHITECTURE behavorial OF diviseurClk IS
BEGIN
  PROCESS (clk, reset)
    VARIABLE cpt_aux : NATURAL := 0;
  BEGIN
    IF (reset = '0') THEN
      cpt_aux := 0;
    ELSIF (rising_edge(clk)) THEN
      cpt_aux := cpt_aux + 1;

      IF cpt_aux = facteur THEN
        cpt_aux := 0;
        nclk <= '1';
      ELSE
        nclk <= '0';
      END IF;
    END IF;
  END PROCESS;
END behavorial;
