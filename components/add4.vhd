library IEEE;
use IEEE.std_logic_1164.all;

entity add4 is
  port (
    X, Y  : in std_logic_vector (3 downto 0);
    Cin   : in std_logic;
    S     : out std_logic_vector (3 downto 0);
    Cout  : out std_logic
  );
end add4;

architecture structural of add4 is

  component add1
    port (
      X, Y, Cin : in std_logic;
      S, Cout   : out std_logic
    );
  end component;

  signal c1, c2, c3: std_logic;
begin
  A1 : add1 port map (X(0), Y(0), Cin, S(0), c1);
  A2 : add1 port map (X(1), Y(1), c1, s(1), c2);
  A3 : add1 port map (X(2), Y(2), c2, s(2), c3);
  A4 : add1 port map (X(3), Y(3), c3, s(3), Cout);
end structural ; -- structural