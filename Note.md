NR Frame：10ms = 10 subFrame = 10 * 1ms

In 1ms:

when SCS=15kHz, 1ms = 1 slot = 14 ofdm symbols

when SCS=30kHz, 1ms = 2 slots = 2*14 ofdm symbols

when SCS=60kHz, 1ms = 4 slots = 4*14 ofdm symbols

when SCS=120kHz, 1ms = 8 slots = 8*14 ofdm symbols


A RB consists of 12 consecutive subCarriers(SC)

The length of SRS signal sequence $M^{SRS}_{sc,b}$:

![image](https://github.com/getOcr/Wilab-/assets/100297318/8ce325fa-fb72-47a5-bc5d-7a84c6c0d3f3)

其中 $m_{SRS,b}$ 是SRS在频域中占用的RB数,取决于查表中的 $B_{SRS}$ and $C_{SRS}$； $P_F$是频率缩放因子（不被高层配置就为1）； $K_{TC}$是传输的comb数（取自2，4，8）





