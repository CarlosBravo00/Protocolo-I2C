library ieee;
use ieee.std_logic_1164.all;


library std;
use std.textio.all;
use ieee.std_logic_textio.all;

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
            SCL : out std_logic;
            I2C_BUSY : out std_logic; 
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
    signal I2C_BUSY : std_logic; 
    signal DATA_READ:  std_logic_vector(7 downto 0);
    signal DATA_SLV : std_logic;
    constant period : time := 10 us; --100khz *Estandar 

begin

    UUT : I2C port map (CLK,enable,reset,I2C_ADDRESS,I2C_DATA,I2C_RW,SDA,SCL,I2C_BUSY,DATA_READ);
    
    clk <= not clk after (period / 2);
    
process
     variable l : line;
    begin
        DATA_SLV <= '1';
        wait until I2C_BUSY'event and I2C_BUSY = '0';
        wait for period;
        wait until I2C_BUSY'event and I2C_BUSY = '0' and I2C_RW = '1';
        DATA_SLV <= '0';


        wait;
    end process;

    SDA <= DATA_SLV when (I2C_BUSY'event and I2C_BUSY = '0') else 'Z';
    I2C_ADDRESS <= "0110001";
    i2C_DATA <= "01111010";
    I2C_RW <= '0';
    enable <= '1' after 4*period, '0' after 8*period;

end arch;
