LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux8_to_1 IS
  GENERIC (size : NATURAL := 4);
  PORT (
    e0, e1, e2, e3,
    e4, e5, e6, e7 : IN STD_LOGIC_VECTOR (size - 1 DOWNTO 0);
    sel            : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
    s              : OUT STD_LOGIC_VECTOR (size - 1 DOWNTO 0));
END mux8_to_1;

ARCHITECTURE behavioral OF mux8_to_1 IS

BEGIN

  WITH sel SELECT
    s <= e0 WHEN "000",
    e1 WHEN "001",
    e2 WHEN "010",
    e3 WHEN "011",
    e4 WHEN "100",
    e5 WHEN "101",
    e6 WHEN "110",
    e7 WHEN "111",
    (OTHERS => 'X') WHEN OTHERS;

END behavioral;
