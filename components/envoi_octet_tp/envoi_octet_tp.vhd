library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity envoi_octet_tp is
  Port ( clk   : in  std_logic;
         reset : in  std_logic;
         en    : in  std_logic;
         data  : in  std_logic_vector (7 downto 0);
         ack   : in  std_logic;
         txd   : out std_logic;
         busy  : out std_logic;
         terr  : out std_logic);
end envoi_octet_tp;

architecture Behavioral of envoi_octet_tp is

  type t_etat is (idle, envoi_data, attente_ack);
  signal etat : t_etat;

begin

  process(clk, reset)
    variable cpt_bit, cpt_ack : natural;
    variable registre : std_logic_vector(7 downto 0);

  begin

    if(reset = '0') then

      -- réinitialisation des variables du process
      -- et des signaux calculés par le process

      -- les compteurs
      cpt_bit := 7;
      cpt_ack := 5;

      -- le registre d'envoi
      registre := (others => 'U');

      -- la ligne série
      txd <= '1';

      -- l'indicateur de fonctionnement/occupation
      busy <= '0';

      -- erreur de transmission (ack pas positionné à temps)
		  terr <= '0';

      -- l'état
      etat <= idle;

    elsif(rising_edge(clk)) then

      -- erreur de transmission à '0' par défaut
      terr <= '0';

      -- front montant de l'horloge
      case etat is

        when idle =>
        -- état d'attente d'un ordre d'envoi

          if(en = '1') then
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

          end if;

        when envoi_data =>

          -- état d'envoi des données
          
          -- on envoie le bit
          txd <= registre(cpt_bit);

          -- si c'était le dernier bit (0), 
          -- on a fini d'envoyer des données
          if(cpt_bit = 0) then
            -- on initialise le compteur d'attente
            -- de la confirmation
            cpt_ack := 5;
            -- on passe à l'état d'attente de la confirmation
            etat <= attente_ack;
          else
            cpt_bit := cpt_bit - 1;
          end if;

        when attente_ack =>
          -- état d'attente de la confirmation
          -- (au plus cpt_ack fronts montants de l'horloge)

          -- on décrémente le compteur d'attente
          cpt_ack := cpt_ack - 1;
          txd <= '1';

          -- si on voit la confirmation
          -- ou si on a attendu suffisamment longtemps
          -- on peut revenir à l'état initial,
          -- l'état d'attente d'un ordre
          if((ack = '1') or (cpt_ack = 0))then

            -- si c'est le ack qui n'est pas arrivé, 
            -- on indique qu'il y a eu une erreur de transmission
            if(ack = '0') then
              terr <= '1';
            end if;

            -- on signale qu'on n'est plus occupé
            busy <= '0';
            -- on revient à l'état initial
            etat <= idle;

          end if;
      end case;
    end if;
  end process;

end Behavioral;
