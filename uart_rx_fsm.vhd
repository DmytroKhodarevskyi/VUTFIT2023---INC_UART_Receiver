-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Dmytro Khodarevskyi (xkhoda01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
        CLK              : in std_logic;
        RST              : in std_logic;
        DIN              : in std_logic;
        ENABLE_REGISTER  : out std_logic;
        COUNT_ENABLE     : out std_logic;
        DOUT_VALID       : out std_logic;
        COUNT_BIT        : in std_logic_vector(4 downto 0);

        OFFSET_BIT     : out std_logic;    
        COUNT_OFFSET      : in std_logic_vector(4 downto 0); -- 1 1000

        COUNT_BYTE       : in std_logic_vector(3 downto 0)
    );
end entity;



architecture behavioral of UART_RX_FSM is

    -- MAKE DELAY STATE ------------------------------------------------
    type STATE_TYPE is (WAIT_START_BIT, MAKE_OFFSET, RECEIVE_DATA, STOP_BIT, DATA_VALID);
    signal CURRENT_STATE : STATE_TYPE := WAIT_START_BIT;
    begin

        process (CURRENT_STATE) begin
            case CURRENT_STATE is
                when RECEIVE_DATA =>
                    ENABLE_REGISTER <= '1';
                    COUNT_ENABLE <= '1';
                when others =>
                    ENABLE_REGISTER <= '0';
                    COUNT_ENABLE <= '0';
            end case;

            case CURRENT_STATE is
                when MAKE_OFFSET =>
                    OFFSET_BIT <= '1';
                when others =>
                    OFFSET_BIT <= '0';
            end case;

            case CURRENT_STATE is
                when DATA_VALID =>
                    DOUT_VALID <= '1';
                when others =>
                    DOUT_VALID <= '0';
            end case;
        end process;

        process (CLK) begin
            if rising_edge(CLK) then
                if RST = '1' then
                CURRENT_STATE <= WAIT_START_BIT;
            else
                case CURRENT_STATE is

                when WAIT_START_BIT =>
                    if DIN = '0' then
                        CURRENT_STATE <= MAKE_OFFSET;
                        -- OFFSET_BIT <= '1';
                    end if;

                when MAKE_OFFSET =>
                    if COUNT_OFFSET = "111" then
                        CURRENT_STATE <= RECEIVE_DATA;
                    end if;

                when RECEIVE_DATA =>
                    if COUNT_BYTE = "1000" then
                        CURRENT_STATE <= DATA_VALID;
                    end if;

                when DATA_VALID =>
                    CURRENT_STATE <= STOP_BIT;

                when STOP_BIT =>
                    if DIN = '1' then
                        CURRENT_STATE <= WAIT_START_BIT;
                    end if;

            when others => null;
            end case;
          end if;
        end if;
      end process;

end architecture;
