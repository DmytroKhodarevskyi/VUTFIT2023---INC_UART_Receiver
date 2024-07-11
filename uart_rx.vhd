-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Dmytro Khodarevskyi (xkhoda01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is

    signal COUNT_BIT        : std_logic_vector(4 downto 0);
    signal COUNT_BYTE       : std_logic_vector(3 downto 0);
    signal ENABLE_REGISTER      : std_logic;
    signal COUNT_ENABLE     : std_logic := '0';
    signal TMP        : std_logic_vector(7 downto 0);
    signal dout_valid : std_logic;

    signal OFFSET_BIT : std_logic;
    signal COUNT_OFFSET : std_logic_vector(4 downto 0) := "00000";

    -- signal delay_count     : std_logic_vector(3 downto 0) := "0000";
    -- variable delay_count : integer range 0 to 7 := 0;
    -- signal delay_count : std_logic_vector(4 downto 0) := "00000";


    

begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (

    CLK                 => clk,
    RST                 => rst,

    DIN                 => din,
    ENABLE_REGISTER     => ENABLE_REGISTER,
    
    COUNT_BIT           => COUNT_BIT,
    COUNT_BYTE          => COUNT_BYTE,
    COUNT_ENABLE        => COUNT_ENABLE,

    OFFSET_BIT          => OFFSET_BIT,    
    COUNT_OFFSET        => COUNT_OFFSET,

    DOUT_VALID          => dout_valid
        
    );

    DOUT_VLD <= dout_valid;
  
    process(CLK) begin

        -- COUNT_ENABLE <= '0';
        
        

        if rising_edge(CLK) then

            -- COUNT_BIT <= "00000";
            -- COUNT_BYTE <= "0000";
             -- Increment counter

        -- if delay_count >= 0 then
            -- If counter reaches 8, wait for one more cycle before continuing
            -- if delay_count = 8 then
            --     delay_count := 0;  -- reset counter
            --     wait for 1 ns;     -- wait for one more cycle
            -- -- continue with the process logic
            -- end if;
            if OFFSET_BIT = '1' then
                -- delay_count <= delay_count + 1;
                COUNT_OFFSET <= COUNT_OFFSET + 1;
                else
                COUNT_OFFSET <= "00000";
            end if;


            -- count enable, increment counter
            if COUNT_ENABLE = '1' then
                -- delay_count <= delay_count + 1;
                COUNT_BIT <= COUNT_BIT + 1;
            else
            -- reset counter
                -- delay_count <= delay_count + 1;
                COUNT_BIT <= "00000";
                COUNT_BYTE <= "0000";
            end if;
            
            if COUNT_ENABLE = '1' then
                -- delay_count <= delay_count + 1;
                -- COUNT_DELAY <= COUNT_DELAY + 1;
            end if;

            if ENABLE_REGISTER = '1' then

                -- wait for half a bit period
                -- wait for 8;
                
                -- 16 clk == 1 bit
                -- if COUNT_BIT = "1111" and delay_count >= "11000" then
                if COUNT_BIT = "1111" then
                    COUNT_BIT <= "00000";

                    -- 8 bit == 1 byte
                    -- write to register 1 by 1

                    case COUNT_BYTE is
                        when "0000" =>
                            TMP(0) <= DIN;
                        when "0001" =>
                            TMP(1) <= DIN;
                        when "0010" =>
                            TMP(2) <= DIN;
                        when "0011" =>
                            TMP(3) <= DIN;
                        when "0100" =>
                            TMP(4) <= DIN;
                        when "0101" =>
                            TMP(5) <= DIN;
                        when "0110" =>
                            TMP(6) <= DIN;
                        when "0111" =>
                            TMP(7) <= DIN;
                        when others => null;
                    end case;
                    COUNT_BYTE <= COUNT_BYTE + 1;
                end if;
            end if;
        end if;
        -- end if;
    end process;
  
    DOUT <= TMP;
end architecture;
