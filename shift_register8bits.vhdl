library ieee;
use ieee.std_logic_1164.all;

entity shift_register8bits is
  port (D:   in std_logic_vector(7 downto 0);
        S:   in std_logic_vector(1 downto 0);
        SL:  in std_logic;
        SR:  in std_logic;
        CLK: in std_logic;
        CLR: in std_logic;
        Q:  out std_logic_vector(7 downto 0));
end entity;

architecture arch of shift_register8bits is

  component shift_register is
      port(
          clk, clr, sdr, sdl : in std_logic;
          mode : in std_logic_vector(1 downto 0);
          parallel : in std_logic_vector(3 downto 0);
          q : out std_logic_vector(3 downto 0)
      );
  end component;

  signal sQ:  std_logic_vector(7 downto 0);
  signal sQ4: std_logic := '0';
  signal sQ3: std_logic := '0';

  begin
    P1: shift_register port map (CLK, CLR, SR, sQ4, S, D(3 downto 0), sQ(3 downto 0));
    P2: shift_register port map (CLK, CLR, sQ3, SL, S, D(7 downto 4), sQ(7 downto 4));
    sQ3 <= sQ(3);
    sQ4 <= sQ(4);
    Q   <= sQ;
end arch;
