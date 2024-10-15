LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY envoi_octet_td IS
  PORT (
    clk   : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    en    : IN STD_LOGIC;
    data  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    ack   : IN STD_LOGIC;
    txd   : OUT STD_LOGIC;
    busy  : OUT STD_LOGIC;
    terr  : OUT STD_LOGIC);
END envoi_octet_td;

ARCHITECTURE Behavioral OF envoi_octet_td IS

  TYPE t_etat IS (idle, envoi_data, attente_ack);
  SIGNAL etat : t_etat;

BEGIN

  PROCESS (clk, reset)
    VARIABLE cpt_bit, cpt_ack : NATURAL;
    VARIABLE registre         : STD_LOGIC_VECTOR(7 DOWNTO 0);

  BEGIN

    IF (reset = '0') THEN

      -- réinitialisation des variables du process
      -- et des signaux calculés par le process

      -- les compteurs
      cpt_bit := 7;
      cpt_ack := 5;

      -- le registre d'envoi
      registre := (OTHERS => 'U');

      -- la ligne série
      txd <= '1';

      -- l'indicateur de fonctionnement/occupation
      busy <= '0';

      -- erreur de transmission (ack pas positionné à temps)
      terr <= '0';

      -- l'état
      etat <= idle;

    ELSIF (rising_edge(clk)) THEN

      -- erreur de transmission à '0' par défaut
      terr <= '0';

      -- front montant de l'horloge
      CASE etat IS

        WHEN idle =>
          -- état d'attente d'un ordre d'envoi

          IF (en = '1') THEN
            -- un ordre est détecté
            -- on signale qu'on est occupé
            busy <= '1';

            -- on stocke l'octet à envoyer
            -- registre est une variable
            -- -> affectation immédiate
            registre := data;

            -- on initialise le compteur de bits 
            -- (variable -> affectation immédiate)
            cpt_bit := 7;

            -- on envoie le bit de poids fort (7)
            -- qui est bien dans la variable registre
            txd <= registre(cpt_bit);

            -- on change d'état
            etat <= envoi_data;

            -- cpt_bit variable, affectation immédiate
            cpt_bit := cpt_bit - 1;

          END IF;

        WHEN envoi_data =>

          -- état d'envoi des données

          -- on envoie le bit
          txd <= registre(cpt_bit);

          -- si c'était le dernier bit (0), 
          -- on a fini d'envoyer des données
          IF (cpt_bit = 0) THEN
            -- on initialise le compteur d'attente
            -- de la confirmation
            cpt_ack := 5;
            -- on passe à l'état d'attente de la confirmation
            etat <= attente_ack;
          ELSE
            cpt_bit := cpt_bit - 1;
          END IF;

        WHEN attente_ack =>
          -- état d'attente de la confirmation
          -- (au plus cpt_ack fronts montants de l'horloge)

          -- on décrémente le compteur d'attente
          cpt_ack := cpt_ack - 1;
          txd <= '1';

          -- si on voit la confirmation
          -- ou si on a attendu suffisamment longtemps
          -- on peut revenir à l'état initial,
          -- l'état d'attente d'un ordre
          IF ((ack = '1') OR (cpt_ack = 0)) THEN

            -- si c'est le ack qui n'est pas arrivé, 
            -- on indique qu'il y a eu une erreur de transmission
            IF (ack = '0') THEN
              terr <= '1';
            END IF;

            -- on signale qu'on n'est plus occupé
            busy <= '0';
            -- on revient à l'état initial
            etat <= idle;

          END IF;
      END CASE;
    END IF;
  END PROCESS;

END Behavioral;
