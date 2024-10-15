--------------------------------------------------------------------------------
-- 
-- VHDL Test Bench Created by ISE for module: envoi_octet_tp
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
 
ENTITY test_envoi_octet_tp IS
END test_envoi_octet_tp;
 
ARCHITECTURE behavior OF test_envoi_octet_tp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
  COMPONENT envoi_octet_tp
    Port ( 
           clk   : in  std_logic;
           reset : in  std_logic;
           en    : in  std_logic;
           data  : in  std_logic_vector (7 downto 0);
           ack   : in  std_logic;
           txd   : out std_logic;
           busy  : out std_logic;
           terr  : out std_logic
         );
  END COMPONENT;
    
   --Inputs
   signal en : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ack : std_logic := '0';

 	--Outputs
   signal txd : std_logic;
   signal busy : std_logic;
   signal terr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

   signal en_ref, txd_ref, busy_ref : std_logic;

BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
  uut: envoi_octet_tp
  PORT MAP (
             clk => clk,
             reset => reset,
             en => en,
             data => data,
             ack => ack, 
             txd => txd,
             busy => busy,
             terr => terr
           );

  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  donneur_ordre: process
  begin		
    -- hold reset state for 100 ns.
    wait for 100 ns;	
    en <= '0';
    reset <= '1';

    wait for clk_period*10;

    -- émission 1
    en <= '1';
    data <= "01001101";

    wait for clk_period;

    -- on rabaisse 'en' et on change data
    -- pour être sûr que la valeur est sauvegardée
    en <= '0';
    data <= "UUUUUUUU";

    -- on attend la fin de l'émission
    wait until busy = '0';
    wait for 6.5*clk_period;

    -- émission 2
    en <= '1';
    data <= "11001011";

    wait for clk_period;
    en <= '0';
    data <= "UUUUUUUU";

    wait;
  end process;

  recepteur: process
  begin		

    ack <= '0';

    -- ack trop tard
    wait for 40*clk_period;
    ack <= '1';
    wait for clk_period;
    ack <= '0';

    -- ack à temps
    wait for 11*clk_period;
    ack <= '1';
    wait for clk_period;
    ack <= '0';
    wait;
  end process;

  -- valeurs attendues de en (décalage possible
  -- si le premier envoi ne dure pas le bon nombre
  -- de tops d'horloge
  en_ref <= '0' after 0 ps,
            '1' after 200000 ps,
            '0' after 210000 ps,
            '1' after 420000 ps,
            '0' after 430000 ps;

  -- valeurs attendues de txd
  txd_ref <= '1' after 0 ps,
             '0' after 205000 ps,
             '1' after 225000 ps,
             '0' after 235000 ps,
             '1' after 255000 ps,
             '0' after 275000 ps,
             '1' after 285000 ps,
             '0' after 295000 ps,
             '1' after 305000 ps,
             '0' after 425000 ps,
             '1' after 435000 ps,
             '0' after 455000 ps,
             '1' after 475000 ps,
             '0' after 485000 ps,
             '1' after 495000 ps;

  -- valeurs attendues de busy
  busy_ref <= '0' after 0 ps,
              '1' after 205000 ps,
              '0' after 355000 ps,
              '1' after 425000 ps,
              '0' after 525000 ps;

  -- à chaque front descendant, on vérifie que les signaux coïncident
  -- avec leurs références
  process(clk)
  begin
    if(falling_edge(clk)) then
      assert(en = en_ref) report "*********** EN FAUX *************" severity error;
      assert(txd = txd_ref) report "*********** TXD FAUX *************" severity error;
      assert(busy = busy_ref) report "*********** BUSY FAUX *************" severity error;
    end if;
  end process;

END;
