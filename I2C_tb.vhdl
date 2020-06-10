library ieee;
use ieee.std_logic_1164.all;

entity I2C_tb is
end entity;

architecture arch of I2C_tb is

    component I2C is
        port(
            clk: in std_logic;
            enable: in std_logic;
            I2C_ADDRESS: in std_logic_vector(6 downto 0);
            I2C_DATA: in std_logic_vector(7 downto 0);
            I2C_RW: in std_logic;
            SDA, SCL : out std_logic
        );
    end component;
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal I2C_ADDRESS : std_logic_vector(6 downto 0);
    signal I2C_DATA : std_logic_vector(7 downto 0);
    signal I2C_RW :std_logic;
    signal SDA :std_logic;
    signal SCL :std_logic;
    constant period : time := 40 ns;

begin

    UUT : I2C port map (CLK,enable,I2C_ADDRESS,I2C_DATA,I2C_RW,SDA,SCL);

    clk_process : process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

    enable <= '1', '0' after 1500 ns;
    I2C_ADDRESS <= "0001011";
    i2C_DATA <= "11001100";
    I2C_RW <= '0';
end arch;
