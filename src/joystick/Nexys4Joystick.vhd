LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4Joystick IS
  PORT (
    -- les 16 switchs
    swt : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : IN STD_LOGIC;
    -- horloge
    mclk : IN STD_LOGIC;

    -- les 16 leds
    led : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

    -- les 3 signaux de communication SPI 
    ss   : OUT STD_LOGIC;
    mosi : OUT STD_LOGIC;
    miso : IN STD_LOGIC;
    sclk : OUT STD_LOGIC
  );
END Nexys4Joystick;

ARCHITECTURE synthesis OF Nexys4Joystick IS

  COMPONENT MasterJoystick IS
    PORT (
      rst     : IN STD_LOGIC;
      clk     : IN STD_LOGIC;
      en      : IN STD_LOGIC;
      inLed1  : IN STD_LOGIC;
      inLed2  : IN STD_LOGIC;
      miso    : IN STD_LOGIC;
      ss      : OUT STD_LOGIC;
      sclk    : OUT STD_LOGIC;
      mosi    : OUT STD_LOGIC;
      x_joy   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      y_joy   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      btn_joy : OUT STD_LOGIC;
      btn_1   : OUT STD_LOGIC;
      btn_2   : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT All7Segments IS
    PORT (
      clk   : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      e0    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e1    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e2    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e3    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e4    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e5    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e6    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      e7    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      an    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      ssg   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
  END COMPONENT;

  SIGNAL reset : STD_LOGIC;
  SIGNAL x_joy : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL y_joy : STD_LOGIC_VECTOR(9 DOWNTO 0);
BEGIN
  -- Reset signal generation
  reset <= NOT btnC;

  -- 13 leds down
  led(15 DOWNTO 3) <= (OTHERS => '0');

  -- MasterJoystick instanciation
  MasterJoystick_inst : MasterJoystick
  PORT MAP(
    rst     => reset,
    clk     => mclk,
    en      => '1',
    inLed1  => btnL,
    inLed2  => btnR,
    miso    => miso,
    ss      => ss,
    sclk    => sclk,
    mosi    => mosi,
    x_joy   => x_joy,
    y_joy   => y_joy,
    btn_joy => led(2),
    btn_1   => led(0),
    btn_2   => led(1)
  );

  -- All7Segments instanciation (7 segments display)
  All7Segments_inst : All7Segments
  PORT MAP(
    clk   => mclk,
    reset => reset,
    e7    => "0000",
    e6    => "00" & x_joy(9 DOWNTO 8),
    e5    => x_joy(7 DOWNTO 4),
    e4    => x_joy(3 DOWNTO 0),

    e3  => "0000",
    e2  => "00" & y_joy(9 DOWNTO 8),
    e1  => y_joy(7 DOWNTO 4),
    e0  => y_joy(3 DOWNTO 0),
    an  => an,
    ssg => ssg
  );
END synthesis;
