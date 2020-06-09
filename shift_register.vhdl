library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
    port(
        clk, clr, sdr, sdl : in std_logic;
        mode : in std_logic_vector(1 downto 0);
        parallel : in std_logic_vector(3 downto 0);
        q : out std_logic_vector(3 downto 0)
    );
end entity;

architecture arch of shift_register is
    signal qn : std_logic_vector(3 downto 0) := "0000";
begin
    process(clr, clk)
    begin
        if clr = '0' then
            qn <= "0000";
        else
            if rising_edge(clk) then
                case mode is
                    when "00" =>
                        qn <= qn;
                    when "01" =>
                        qn <= qn(2 downto 0) & sdr;
                    when "10" =>
                        qn <= sdl & qn(3 downto 1);
                    when "11" =>
                        qn <= parallel;
                    when others =>
                        null;
                end case;
                q <= qn;
            end if;
        end if;
    end process;

    q <= qn;
end arch ; -- arch
