library ieee;
use ieee.std_logic_1164.all;

entity I2C_tb is
end entity;

architecture arch of I2C_tb is

    component I2C_SLV is
        port(
            I2C_ADDRESS: in std_logic_vector(6 downto 0); --Direccio del esclavo 
            I2C_DATA: in std_logic_vector(7 downto 0); --Data en el esclavo
            DATA_WRITE: out std_logic_vector(7 downto 0); --Data que recive el esclavo
            SCL: in std_logic;--SCL = Serial Clock 
            SDA : inout std_logic; --SDA = Serial Data/Address  
            SLV_BUSY : out std_logic --1 Busy,0 Espera respuesta
        );
    end component;
    signal I2C_ADDRESS : std_logic_vector(6 downto 0);
    signal I2C_DATA : std_logic_vector(7 downto 0);
    signal SDA :std_logic;
    signal SCL :std_logic;
    signal SLV_BUSY : std_logic;
    signal DATA_WRITE:  std_logic_vector(7 downto 0);

    signal SENT_ADDRESS : std_logic_vector (6 downto 0);
    signal SENT_DATA : std_logic_Vector (7 downto 0)
    signal SENT_RW : std_logic;
    constant period : time := 10 us;

begin

    UUT : I2C_tb port map (I2C_ADDRESS,I2C_DATA,DATA_WRITE,SCL,SDA,SLV_BUSY);

process
    begin
        SCL <= 'H';
        DATA_SLV  <= 'H';

        wait for (period / 2);
        -- start bit
        DATA_SLV <= '1';
        wait for (bit_period / 2);
        SCL <= '0'; 
        wait for (bit_period / 2);
        SCL <= '1';

        wait until SLV_BUSY'event and SLV_BUSY = '0'; --ACK de Address
        wait for period;
        wait until SLV_BUSY'event and SLV_BUSY = '0' and I2C_RW = '1';
        for i in 0 to 7 loop
            DATA_SLV<= RD_DATA(7-i); --Si es lectura manda la informacion de leer
            wait until SCL'event and SCL = '0';
        end loop;


        wait;
    end process;

    SDA <= DATA_MASTER when (SLV_BUSY = '1') else 'Z';

    I2C_ADDRESS <= "0110001";
    I2C_DATA <= "01111010";

    SENT_ADDRESS <= "0110001";
    SENT_DATA <= "110100010";
    SENT_RW <= '1';

end arch;
