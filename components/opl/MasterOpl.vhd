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

BEGIN

END behavior;
