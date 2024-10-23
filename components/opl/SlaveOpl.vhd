LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SlaveOpl IS
  PORT (
    sclk : IN STD_LOGIC;
    mosi : IN STD_LOGIC;
    miso : OUT STD_LOGIC;
    ss   : IN STD_LOGIC
  );
END SlaveOpl;

--------------------------------------------------------------------------------

ARCHITECTURE behavioral OF SlaveOpl IS

  SIGNAL v1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'U');
  SIGNAL v2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'U');
  -- les valeurs initiales de val_xor, val_and et val_or
  -- sont les valeurs émises -- lors de la première transmission
  SIGNAL val_xor : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110011";
  SIGNAL val_and : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10100000";
  SIGNAL val_or  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";

  SIGNAL count_mosi     : NATURAL; -- bit index dans l'octet à recevoir
  SIGNAL num_octet_mosi : NATURAL; -- index de l'octet à recevoir

  SIGNAL count_miso     : NATURAL; -- bit index dans l'octet à envoyer
  SIGNAL num_octet_miso : NATURAL; -- index de l'octet à envoyer

BEGIN

  -- process de capture des 3 octets sur front montant de sclk
  capture : PROCESS (ss, sclk)
  BEGIN
    IF (ss = '1') THEN -- ss est un reset asynchrone
      count_mosi     <= 7;
      num_octet_mosi <= 0;
    ELSIF (rising_edge(sclk)) THEN
      CASE (num_octet_mosi) IS
        WHEN 0 =>
          v1(count_mosi) <= mosi;
          --
          IF (count_mosi > 0) THEN
            count_mosi <= count_mosi - 1;
          ELSE
            count_mosi     <= 7;
            num_octet_mosi <= num_octet_mosi + 1;
          END IF;

        WHEN 1 =>
          v2(count_mosi) <= mosi;
          --
          IF (count_mosi > 0) THEN
            count_mosi <= count_mosi - 1;
          ELSE
            count_mosi     <= 7;
            num_octet_mosi <= num_octet_mosi + 1;
          END IF;

        WHEN OTHERS =>
          IF (count_mosi > 0) THEN
            count_mosi <= count_mosi - 1;
          ELSE
            count_mosi     <= 7;
            num_octet_mosi <= 0;
            --
            val_xor <= v1 XOR v2;
            val_and <= v1 AND v2;
            val_or  <= v1 OR v2;
          END IF;
      END CASE;
    END IF;
  END PROCESS;
  -- process de "présentation" des 3 octets : val_xor, val_and et val_or
  envoi : PROCESS (ss, sclk)
  BEGIN
    IF (ss = '1') THEN -- ss est un reset asynchrone
      count_miso     <= 7;
      num_octet_miso <= 0;
    ELSIF (falling_edge(sclk)) THEN
      CASE (num_octet_miso) IS
        WHEN 0 =>
          miso <= val_xor(count_miso);
          --
          IF (count_miso > 0) THEN
            count_miso <= count_miso - 1;
          ELSE
            count_miso     <= 7;
            num_octet_miso <= num_octet_miso + 1;
          END IF;

        WHEN 1 =>
          miso <= val_and(count_miso);
          --
          IF (count_miso > 0) THEN
            count_miso <= count_miso - 1;
          ELSE
            count_miso     <= 7;
            num_octet_miso <= num_octet_miso + 1;
          END IF;

        WHEN OTHERS =>
          miso <= val_or(count_miso);
          --
          IF (count_miso > 0) THEN
            count_miso <= count_miso - 1;
          ELSE
            count_miso     <= 7;
            num_octet_miso <= 0;
          END IF;
      END CASE;
    END IF;
  END PROCESS;

END behavioral;
