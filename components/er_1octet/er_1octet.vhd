LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY er_1octet IS
  PORT (
    rst  : IN STD_LOGIC;
    clk  : IN STD_LOGIC;
    en   : IN STD_LOGIC;
    din  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    miso : IN STD_LOGIC;
    sclk : OUT STD_LOGIC;
    mosi : OUT STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    busy : OUT STD_LOGIC);
END er_1octet;

ARCHITECTURE behavioral OF er_1octet IS
  TYPE t_etat IS (idle, rec_bit, send_bit);
  SIGNAL etat : t_etat;
BEGIN
  PROCESS (clk, rst)
    VARIABLE cpt_bit : NATURAL;
    VARIABLE reg     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    IF (rst = '0') THEN
      busy <= '0';
      sclk <= '1';

    ELSIF rising_edge(clk) THEN
      CASE etat IS
        WHEN idle =>
          IF (en = '1') THEN
            busy <= '1';
            sclk <= '0';
            reg     := din;
            cpt_bit := 7;
            mosi <= reg(cpt_bit);
            etat <= rec_bit;
          END IF;

        WHEN rec_bit =>
          sclk <= '1';
          IF (cpt_bit = 0) THEN
            busy <= '0';
            reg(cpt_bit) := miso;
            dout <= reg;
            etat <= idle;
          ELSE
            reg(cpt_bit) := miso;
            etat <= send_bit;
          END IF;

        WHEN send_bit =>
          sclk <= '0';
          cpt_bit := cpt_bit - 1;
          mosi <= reg(cpt_bit);
          etat <= rec_bit;
      END CASE;

    END IF;
  END PROCESS;
END behavioral;
