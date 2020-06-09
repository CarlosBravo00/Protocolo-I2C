library ieee;
use ieee.std_logic_1164.all;

entity shift_register8bits_tb is
end entity;

architecture behavioral of shift_register8bits_tb is

  component shift_register8bits is
    port (D:   in std_logic_vector(7 downto 0);
          S:   in std_logic_vector(1 downto 0);
          SL:  in std_logic;
          SR:  in std_logic;
          CLK: in std_logic;
          CLR: in std_logic;
          Q:  out std_logic_vector(7 downto 0));
  end component;

  signal sD: std_logic_vector(7 downto 0) := "00000000";
  signal sQ: std_logic_vector(7 downto 0) := "00000000";
  signal sS: std_logic_vector(1 downto 0);
  signal sCLK: std_logic;
  signal sCLR: std_logic;
  signal sSL: std_logic;
  signal sSR: std_logic;

  constant period : time := 10 ns;

  begin

    UUT: shift_register8bits port map (sD, sS, sSL, sSR, sCLK, sCLR, sQ);

    CLK_Process : Process
    begin
      sCLK <= '0';
      wait for period/2;
      sCLK <= '1';
      wait for period/2;
  end process;

  sD  <= "00110101";
  sSL <= '0' ;
  sSR <= '1' ;

  sCLR <= '0', '1' after period*2, '0'  after period*15;
  sS <= "00", "11" after period*2, "10" after period*4, "11" after period*8, "01" after period*10, "00" after period*14;

end behavioral;
