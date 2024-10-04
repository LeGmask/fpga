LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_ARITH.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY test_compteur IS
END test_compteur;

ARCHITECTURE behavior OF test_compteur IS
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

   --Inputs
   SIGNAL clk   : STD_LOGIC := '0';
   SIGNAL reset : STD_LOGIC := '0';

   --Outputs
   SIGNAL cpt   : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL carry : STD_LOGIC;

   -- Clock period definitions
   CONSTANT clk_period : TIME := 10 ns;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut : compteur GENERIC MAP(N => 4)
   PORT MAP(
      clk   => clk,
      reset => reset,
      cpt   => cpt,
      carry => carry
   );

   -- Clock process definitions
   clk_process : PROCESS
   BEGIN
      clk <= '0';
      WAIT FOR clk_period/2;
      clk <= '1';
      WAIT FOR clk_period/2;
   END PROCESS;
   -- Stimulus process
   stim_proc : PROCESS
   BEGIN
      -- hold reset state for 100 ns.
      WAIT FOR 100 ns;
      reset <= '0';
      WAIT FOR clk_period * 10;

      reset <= '1';

      WAIT;
   END PROCESS;

END;
