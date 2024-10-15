LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY test_er_1octet_automate IS
END test_er_1octet_automate;

ARCHITECTURE behavior OF test_er_1octet_automate IS

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

  --Inputs
  SIGNAL clk    : STD_LOGIC                    := '0';
  SIGNAL reset  : STD_LOGIC                    := '0';
  SIGNAL en_er  : STD_LOGIC                    := '0';
  SIGNAL din_er : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL miso   : STD_LOGIC                    := '0';

  --Outputs
  SIGNAL busy_er : STD_LOGIC;
  SIGNAL dout_er : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL sclk    : STD_LOGIC;
  SIGNAL mosi    : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clk_period : TIME := 10 ns;

  -- types
  TYPE t_etat IS (debut, attente_active, echange_octet, fin);

  -- signaux internes   
  SIGNAL etat : t_etat;

  SIGNAL mosi_ref : STD_LOGIC;
  SIGNAL sclk_ref : STD_LOGIC;
  SIGNAL busy_ref : STD_LOGIC;
  SIGNAL dout_ref : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

  m : er_1octet
  PORT MAP(
    clk  => clk,
    rst  => reset,
    en   => en_er,
    busy => busy_er,
    din  => din_er,
    dout => dout_er,
    sclk => sclk,
    miso => miso,
    mosi => mosi
  );

  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  reset <= '0', '1' AFTER 100 ns;

  -- process permettant d'échanger 2 octets
  stim_proc : PROCESS (clk, reset)
    -- variables 
    VARIABLE cpt_att   : NATURAL;
    VARIABLE cpt_octet : NATURAL;
  BEGIN
    IF (reset = '0') THEN
      cpt_octet := 0;
      en_er  <= '0';
      din_er <= (OTHERS => 'U');
      etat   <= debut;
    ELSIF (rising_edge(clk)) THEN

      CASE etat IS

        WHEN debut =>
          -- attente de 10 cycles de l'horloge
          -- avant le premier octet
          cpt_att   := 10;
          cpt_octet := 0;
          etat <= attente_active;

        WHEN attente_active =>
          cpt_att := cpt_att - 1;
          IF (cpt_att = 0) THEN
            -- on a attendu assez longtemps

            -- valeur de l'octet envoyé
            IF (cpt_octet = 0) THEN
              din_er <= "10110101";
            ELSE
              din_er <= "01010100";
            END IF;
            -- on lance l'échange d'un octet en activant
            -- le sous-composant
            en_er <= '1';
            etat  <= echange_octet;
          END IF;

        WHEN echange_octet =>
          -- on rabaisse l'ordre passé au sous-composant
          en_er  <= '0';
          din_er <= (OTHERS => 'U');

          IF (en_er = '0' AND busy_er = '0') THEN
            -- échange d'1 octet terminé

            -- on prépare la suite
            IF (cpt_octet = 0) THEN
              -- il reste des octets à transmettre
              cpt_octet := cpt_octet + 1;
              -- attente de 5 cycles entre les deux octets
              cpt_att := 5;
              etat <= attente_active;
            ELSE
              -- on a envoyé 2 octets, c'est fini
              etat <= fin;
            END IF;

          END IF;

        WHEN fin => NULL;

      END CASE;

    END IF;
  END PROCESS;

  -- process qui génère le signal miso
  genere_miso : PROCESS (clk, reset)
    VARIABLE cpt : NATURAL;

  BEGIN
    IF (reset = '0') THEN
      miso <= '0';
      cpt := 0;
    ELSIF (falling_edge(clk)) THEN
      cpt := (cpt + 1) MOD 7;
      IF (cpt < 3) THEN
        miso <= '0';
      ELSE
        miso <= '1';
      END IF;
    END IF;
  END PROCESS genere_miso;

  --
  -- pour vérifier si mosi, sclk, busy et dout sont corrects
  busy_ref <= '0' AFTER 0 ps,
    '1' AFTER 215000 ps,
    '0' AFTER 365000 ps,
    '1' AFTER 435000 ps,
    '0' AFTER 585000 ps;

  dout_ref <= "UUUUUUUU" AFTER 0 ps,
    "10110011" AFTER 365000 ps,
    "00110110" AFTER 585000 ps;

  mosi_ref <= 'U' AFTER 0 ps,
    '1' AFTER 215000 ps,
    '0' AFTER 235000 ps,
    '1' AFTER 255000 ps,
    '0' AFTER 295000 ps,
    '1' AFTER 315000 ps,
    '0' AFTER 335000 ps,
    '1' AFTER 355000 ps,
    '0' AFTER 435000 ps,
    '1' AFTER 455000 ps,
    '0' AFTER 475000 ps,
    '1' AFTER 495000 ps,
    '0' AFTER 515000 ps,
    '1' AFTER 535000 ps,
    '0' AFTER 555000 ps;

  sclk_ref <= '1' AFTER 0 ps,
    '0' AFTER 215000 ps,
    '1' AFTER 225000 ps,
    '0' AFTER 235000 ps,
    '1' AFTER 245000 ps,
    '0' AFTER 255000 ps,
    '1' AFTER 265000 ps,
    '0' AFTER 275000 ps,
    '1' AFTER 285000 ps,
    '0' AFTER 295000 ps,
    '1' AFTER 305000 ps,
    '0' AFTER 315000 ps,
    '1' AFTER 325000 ps,
    '0' AFTER 335000 ps,
    '1' AFTER 345000 ps,
    '0' AFTER 355000 ps,
    '1' AFTER 365000 ps,
    '0' AFTER 435000 ps,
    '1' AFTER 445000 ps,
    '0' AFTER 455000 ps,
    '1' AFTER 465000 ps,
    '0' AFTER 475000 ps,
    '1' AFTER 485000 ps,
    '0' AFTER 495000 ps,
    '1' AFTER 505000 ps,
    '0' AFTER 515000 ps,
    '1' AFTER 525000 ps,
    '0' AFTER 535000 ps,
    '1' AFTER 545000 ps,
    '0' AFTER 555000 ps,
    '1' AFTER 565000 ps,
    '0' AFTER 575000 ps,
    '1' AFTER 585000 ps;
  PROCESS (clk)
  BEGIN
    IF (falling_edge(clk)) THEN
      ASSERT(mosi = mosi_ref) REPORT "mosi faux"
      SEVERITY error;
      ASSERT(sclk = sclk_ref) REPORT "sclk faux"
      SEVERITY error;
      ASSERT(busy_er = busy_ref) REPORT "busy faux"
      SEVERITY error;
      ASSERT(dout_er = dout_ref) REPORT "dout faux"
      SEVERITY error;
    END IF;
  END PROCESS;

END behavior;
