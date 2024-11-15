LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MasterOpl IS
  PORT (
    rst     : IN STD_LOGIC;
    clk     : IN STD_LOGIC;
    en      : IN STD_LOGIC;
    v1      : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    v2      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    miso    : IN STD_LOGIC;
    ss      : OUT STD_LOGIC;
    sclk    : OUT STD_LOGIC;
    mosi    : OUT STD_LOGIC;
    val_xor : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    val_and : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    val_or  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    busy    : OUT STD_LOGIC);
END MasterOpl;

ARCHITECTURE behavior OF MasterOpl IS
  -- The state of the FSM
  TYPE t_state IS (idle, sync, exchange, exchange_wait);
  -- The signal tracking the state of the FSM
  SIGNAL state : t_state;

  COMPONENT er_1octet
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
  END COMPONENT;

  SIGNAL din     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL dout    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL buff_v1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL buff_v2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL enER    : STD_LOGIC;
  SIGNAL enBusy  : STD_LOGIC;
BEGIN

  er_1octet_inst : er_1octet
  PORT MAP(
    rst  => rst,
    clk  => clk,
    en   => enER,
    din  => din,
    miso => miso,
    sclk => sclk,
    mosi => mosi,
    dout => dout,
    busy => enBusy
  );

  PROCESS (clk, rst)
    -- Variable used to count the number of clock cycles
    VARIABLE tick_count : NATURAL := 0;
    -- Variable to know which message we are sending
    VARIABLE exchange_count : NATURAL := 0;
    -- Variable to know if we are sending the last message
    VARIABLE isLast : BOOLEAN := false;
    -- Variable to know if we are sending a message
    VARIABLE sending : BOOLEAN := false;
  BEGIN
    IF (rst = '0') THEN
      -- We are in reset state
      -- Reset all signals
      tick_count     := 0;
      exchange_count := 0;
      isLast         := false;

      enER  <= '0';
      busy  <= '0';
      ss    <= '1';
      state <= idle;
    ELSIF rising_edge(clk) THEN
      CASE state IS
        WHEN idle =>
          IF (en = '1') THEN
            -- Waking up, 
            tick_count := 0;
            busy <= '1';
            ss   <= '0';

            -- Saving the data to send
            buff_v1 <= v1;
            buff_v2 <= v2;

            -- Waiting for synchronization
            state <= sync;
          END IF;

        WHEN sync =>
          -- This is the synchronization state
          -- We are waiting for 10 clock cycles
          tick_count := tick_count + 1;
          IF tick_count >= 10 THEN
            tick_count := 0;
            state <= exchange;
          END IF;

        WHEN exchange =>
          CASE exchange_count IS
              -- For each exchange, we are sending a message,
              -- First we are activating the er_1octet component by setting enER to '1'
              -- On the next clock cycle, we are deactivating the er_1octet component by setting enER to '0'
              -- This is used in order to avoid sending multiple messages next to each other
              -- Once we are done with the exchange (enBusy = '0'), we are saving the value of the received message
              -- Then we go to the exchange_wait state to wait for 3 clock cycles before sending the next message
            WHEN 0 => -- Exchanging the first message
              IF (NOT sending) AND enER = '0' AND enBusy = '0' THEN
                din  <= buff_v1;
                enER <= '1';
                sending := true;
              ELSIF sending AND enER = '1' AND enBusy = '0' THEN
                enER <= '0';
              ELSIF sending AND enER = '0' AND enBusy = '0' THEN
                sending := false;
                val_xor <= dout;
                state   <= exchange_wait;
              END IF;

            WHEN 1 => -- Exchanging the second message
              IF (NOT sending) AND enER = '0' AND enBusy = '0' THEN
                din  <= buff_v2;
                enER <= '1';
                sending := true;
              ELSIF sending AND enER = '1' AND enBusy = '0' THEN
                enER <= '0';
              ELSIF sending AND enER = '0' AND enBusy = '0' THEN
                sending := false;

                val_and <= dout;
                state   <= exchange_wait;
              END IF;

            WHEN 2 => -- Exchanging the third message
              IF (NOT sending) AND enER = '0' AND enBusy = '0' THEN
                -- We are sending 0 since we are not using this value
                din  <= "00000000";
                enER <= '1';
                sending := true;
              ELSIF sending AND enER = '1' AND enBusy = '0' THEN
                enER <= '0';
              ELSIF sending AND enER = '0' AND enBusy = '0' THEN
                sending := false;
                val_or <= dout;

                isLast := true;
                state <= exchange_wait;
              END IF;

            WHEN OTHERS => NULL; -- Do nothing (should not happen)
          END CASE;

        WHEN exchange_wait =>
          -- We are waiting for 3 clock cycles between each exchange
          tick_count := tick_count + 1;
          IF tick_count >= 3 THEN
            tick_count     := 0;
            exchange_count := exchange_count + 1;

            IF isLast THEN
              -- We are done with the exchange
              -- Reset all signals and variables
              exchange_count := 0;
              isLast         := false;

              busy  <= '0';
              ss    <= '1';
              state <= idle;
            ELSE
              -- Do another exchange
              state <= exchange;
            END IF;
          END IF;
      END CASE;
    END IF;
  END PROCESS;
END behavior;
