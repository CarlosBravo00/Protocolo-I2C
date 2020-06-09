library ieee;
use ieee.std_logic_1164.all;

entity I2C_tb is
end entity;

architecture arch of I2C_tb is

    component I2C is
        port(
          
        );
    end component;

    constant period : time := 10 ns;

begin

    UUT : I2C port map ();

    clk_process : process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

end arch;
