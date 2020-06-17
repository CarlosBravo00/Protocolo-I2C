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
    signal I2C_BUSY : std_logic := '0';
    signal DATA_READ:  std_logic_vector(7 downto 0);
    signal DATA_SLV : std_logic;
    signal RD_DATA : std_logic_vector(7 downto 0);
    constant period : time := 10 us; --100khz *Estandar


begin


    UUT : I2C port map (CLK,enable,reset,I2C_ADDRESS,I2C_DATA,I2C_RW,SDA,SCL,I2C_BUSY,DATA_READ);

--Cambio en el periodo--
    clk <= not clk after (period / 2);

process
    begin
        DATA_SLV <= '1';
        wait until I2C_BUSY'event and I2C_BUSY = '0'; --ACK de Address
        wait for period;
        wait until I2C_BUSY'event and I2C_BUSY = '0' and I2C_RW = '1';
--SIMULACION DEL ESCLAVO--READ---
        for i in 0 to 7 loop
            DATA_SLV<= RD_DATA(7-i); --Si es lectura manda la informacion de leer
            wait until SCL'event and SCL = '0';
        end loop;
        wait;
    end process;

process 
     variable l : line;
     file fin : TEXT open READ_MODE is "Masterinput.txt";
     variable current_read_line : line;
     variable current_read_field : string(1 to 4);
     variable current_read_data : std_logic;
     variable current_read_dataADD : std_logic_vector(6 downto 0);
     variable current_read_dataDAT : std_logic_vector(7 downto 0);
     variable current_write_line : line;
    begin
        readline(fin, current_read_line);
        read(current_read_line, current_read_field);
        read(current_read_line, current_read_dataADD);
            I2C_ADDRESS <= current_read_dataADD; 
        readline(fin, current_read_line);
        read(current_read_line, current_read_field);
        read(current_read_line, current_read_data);
            I2C_RW  <= current_read_data;
        readline(fin, current_read_line);
        read(current_read_line, current_read_field);
        read(current_read_line, current_read_dataDAT);
            I2C_DATA <= current_read_dataDAT;
        wait for  4*period;
        enable <= '1';
        wait for  4*period;
        enable <= '0';

        if (I2C_RW = '1') then    
            wait until DATA_READ /= "UUUUUUUU";
                write (l, string'("DATA READ: "));
                write (l, DATA_READ);
                writeline(output, l);
        end if;
        wait for 300* period;
    end process;

    SDA <= DATA_SLV when (I2C_BUSY = '0') else 'Z';
   -- enable <= '1' after 4*period, '0' after 8*period;
    RD_DATA <= "11010010"; --Slave data 
    --I2C_ADDRESS <= "0110001";
    --I2C_DATA <= "01111010";
    --I2C_RW <= '1';

end arch;
