--------------------------------------------------------------------------------
-- 
-- VHDL Test Bench Created by ISE for module: envoi_octet_td
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY test_envoi_octet_td IS
END test_envoi_octet_td;

ARCHITECTURE behavior OF test_envoi_octet_td IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT envoi_octet_td
    PORT (
      clk   : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      en    : IN STD_LOGIC;
      data  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      ack   : IN STD_LOGIC;
      txd   : OUT STD_LOGIC;
      busy  : OUT STD_LOGIC;
      terr  : OUT STD_LOGIC
    );
  END COMPONENT;

  --Inputs
  SIGNAL en    : STD_LOGIC                    := '0';
  SIGNAL data  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL clk   : STD_LOGIC                    := '0';
  SIGNAL reset : STD_LOGIC                    := '0';
  SIGNAL ack   : STD_LOGIC                    := '0';

  --Outputs
  SIGNAL txd  : STD_LOGIC;
  SIGNAL busy : STD_LOGIC;
  SIGNAL terr : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clk_period : TIME := 10 ns;

  SIGNAL txd_ref : STD_LOGIC;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : envoi_octet_td
  PORT MAP(
    clk   => clk,
    reset => reset,
    en    => en,
    data  => data,
    ack   => ack,
    txd   => txd,
    busy  => busy,
    terr  => terr
  );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  donneur_ordre : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;
    en    <= '0';
    reset <= '1';

    WAIT FOR clk_period * 10;

    -- émission 1
    en   <= '1';
    data <= "01001101";

    WAIT FOR clk_period;

    -- on rabaisse 'en' et on change data
    -- pour être sûr que la valeur est sauvegardée
    en   <= '0';
    data <= "UUUUUUUU";

    -- on attend la fin de l'émission
    WAIT UNTIL busy = '0';

    WAIT FOR 5 * clk_period;

    -- émission 2
    en   <= '1';
    data <= "11001001";

    WAIT FOR clk_period;
    en   <= '0';
    data <= "UUUUUUUU";

    WAIT;
  END PROCESS;

  recepteur : PROCESS
  BEGIN

    ack <= '0';

    -- ack trop tard
    WAIT FOR 35 * clk_period;
    ack <= '1';
    WAIT FOR clk_period;
    ack <= '0';

    -- ack à temps
    WAIT FOR 10 * clk_period;
    ack <= '1';
    WAIT FOR clk_period;
    ack <= '0';

    WAIT;
  END PROCESS;

  -- valeurs attendues de txd
  txd_ref <= '1' AFTER 0 ps,
    '0' AFTER 205000 ps,
    '1' AFTER 215000 ps,
    '0' AFTER 225000 ps,
    '1' AFTER 245000 ps,
    '0' AFTER 265000 ps,
    '1' AFTER 275000 ps,
    '0' AFTER 395000 ps,
    '1' AFTER 415000 ps,
    '0' AFTER 425000 ps,
    '1' AFTER 445000 ps;

  -- à chaque front descendant, on vérifie que txd et txd_ref coïncident
  PROCESS (clk)
  BEGIN
    IF (falling_edge(clk)) THEN
      ASSERT(txd = txd_ref) REPORT "*********** TXD FAUX *************"
      SEVERITY error;
    END IF;
  END PROCESS;

END;
