LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- interface du composant additionneur
ENTITY add1 IS
  PORT (
    X, Y, Cin : IN STD_LOGIC;
    S, Cout   : OUT STD_LOGIC
  );
END add1;

ARCHITECTURE vue_flot OF add1 IS
  CONSTANT delay : TIME := 2 ns;

  -- signal local
  SIGNAL i : STD_LOGIC;
BEGIN
  -- 3 équations logiques qui calculent i, Cout et S ==
  -- 3 instructions concurrentes
  S    <= i XOR Cin AFTER delay;
  Cout <= (X AND Y) OR (i AND Cin) AFTER 2 * delay;
  i    <= X XOR Y AFTER delay;
END vue_flot;
