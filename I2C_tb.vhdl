library ieee;
use ieee.std_logic_1164.all;

entity I2C_tb is
end entity;

architecture arch of I2C_tb is

    component I2C is
        port(
            clk: in std_logic;
            enable: in std_logic;
            reset: in std_logic; 
            I2C_ADDRESS: in std_logic_vector(6 downto 0);
            I2C_DATA: in std_logic_vector(7 downto 0);
            I2C_RW: in std_logic;
            SDA : inout std_logic; 
            SCL : inout std_logic;
            DATA_READ: out std_logic_vector(7 downto 0)
        );
    end component;
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal reset : std_logic := '0';
    signal I2C_ADDRESS : std_logic_vector(6 downto 0);
    signal I2C_DATA : std_logic_vector(7 downto 0);
    signal I2C_RW :std_logic;
    signal SDA :std_logic;
    signal SCL :std_logic;
    signal DATA_READ:  std_logic_vector(7 downto 0);
    constant period : time := 10 us; --100khz *Estandar 

begin

    UUT : I2C port map (CLK,enable,reset,I2C_ADDRESS,I2C_DATA,I2C_RW,SDA,SCL,DATA_READ);

    clk_process : process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

    enable <= '1' after 3 us, '0' after 300 us;
    --reset <= '1' after 150 us, '0' after 200 us; 
    I2C_ADDRESS <= "0110001";
    i2C_DATA <= "01111010";
    I2C_RW <= '0';
end arch;
