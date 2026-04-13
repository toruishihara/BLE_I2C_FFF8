
# Connecting Si1145 to nRF5340-DK

## Hardware Connection

The nRF5340-DK has several rows of female header pins along its edges, designed for compatibility with Arduino Uno shields. These are typically where you'll connect external components.

Connect the Si1145 breakout board to the nRF5340-DK as follows:

1.  **Locate the power pins:**
    *   Find a pin labeled **"3V3"** or **"VDD"** on one of the female headers. This is your 3.3V power source. It's often found near other power-related pins (like 5V or GND).
    *   Find a pin labeled **"GND"** (Ground). There are usually several scattered across the headers.
2.  **Locate the I2C communication pins:**
    *   These are usually found on one of the longer female headers. Look for pins typically corresponding to **Analog Pin 4 (A4)** for **SDA** and **Analog Pin 5 (A5)** for **SCL** on an Arduino Uno layout. On the nRF5340-DK, these often correspond to **GPIO P0.26 (SDA)** and **GPIO P0.27 (SCL)**, though they might not be explicitly labeled as such on the header itself.

Here's a summary of the connections:

| AS7331 Pin | nRF5340-DK Connection | Description |
|------------|-----------------------|-------------|
| VIN        | 3.3V pin              | Connect to a pin labeled "3V3" or "VDD" |
| GND        | GND pin               | Connect to any pin labeled "GND" |
| SDA        | SDA (Analog Pin A4)   | Corresponds to GPIO P0.26 |
| SCL        | SCL (Analog Pin A5)   | Corresponds to GPIO P0.27 |

Build command :
```
west build -p always -b nrf5340dk/nrf5340/cpuapp
```

Flash command :
```
west flash
```

Build env
```
(.venv) (base) torui@Torus-MacBook-Air nRF53FW % python --version
Python 3.10.19
(.venv) (base) torui@Torus-MacBook-Air nRF53FW % echo $VIRTUAL_ENV
/Users/torui/zephyrproject/.venv
(.venv) (base) torui@Torus-MacBook-Air nRF53FW % west --version
West version: v1.5.0
(.venv) (base) torui@Torus-MacBook-Air nRF53FW % west list
manifest     zephyr                       HEAD                                     N/A
acpica       modules/lib/acpica           8d24867bc9c9d81c81eeac59391cda59333affd4 https://github.com/zephyrproject-rtos/acpica
cmsis        modules/hal/cmsis            512cc7e895e8491696b61f7ba8066b4a182569b8 https://github.com/zephyrproject-rtos/cmsis
cmsis-dsp    modules/lib/cmsis-dsp        97512610ec92058f0119450b9e743eeb7e95b5c8 https://github.com/zephyrproject-rtos/cmsis-dsp
cmsis-nn     modules/lib/cmsis-nn         e9328d612ea3ea7d0d210d3ac16ea8667c01abdd https://github.com/zephyrproject-rtos/cmsis-nn
cmsis_6      modules/hal/cmsis_6          30a859f44ef8ab4dc8f84b03ed586fd16ccf9d74 https://github.com/zephyrproject-rtos/CMSIS_6
edtt         tools/edtt                   c282625e694f0b53ea53e13231ea6d2f49411768 https://github.com/zephyrproject-rtos/edtt
fatfs        modules/fs/fatfs             f4ead3bf4a6dab3a07d7b5f5315795c073db568d https://github.com/zephyrproject-rtos/fatfs
hal_adi      modules/hal/adi              4a189d5d2d20267084d9066cd0c4548dd730f809 https://github.com/zephyrproject-rtos/hal_adi
hal_afbr     modules/hal/afbr             1abf6947457380934e27f92508ec5532ddedfc6d https://github.com/zephyrproject-rtos/hal_afbr
hal_ambiq    modules/hal/ambiq            5efc0228528a8adce5eae0d226fac85d2551eb3b https://github.com/zephyrproject-rtos/hal_ambiq
hal_atmel    modules/hal/atmel            065e57c5013051c8b7f2256271349c6942bd9344 https://github.com/zephyrproject-rtos/hal_atmel
hal_bouffalolab modules/hal/bouffalolab      ebecd183d4f52225e465d056f457792e4ebe80c1 https://github.com/zephyrproject-rtos/hal_bouffalolab
hal_espressif modules/hal/espressif        19807014b69b2dc24edb7a1b49c915fd58083527 https://github.com/zephyrproject-rtos/hal_espressif
hal_ethos_u  modules/hal/ethos_u          fd5d5b7b36b209f2c48635de5d6c9b8dbf0bfff0 https://github.com/zephyrproject-rtos/hal_ethos_u
hal_gigadevice modules/hal/gigadevice       ee0e31302c21b2a465dc303b3ced8c606c2167c8 https://github.com/zephyrproject-rtos/hal_gigadevice
hal_infineon modules/hal/infineon         470f874ce432763a2b82cd322d0ff6efc89240cd https://github.com/zephyrproject-rtos/hal_infineon
hal_intel    modules/hal/intel            82a33b2de29523d9ce572b3d0110a808665cd3ff https://github.com/zephyrproject-rtos/hal_intel
hal_microchip modules/hal/microchip        dbbff4a054d5888c3e8a27096335197a1a8186ca https://github.com/zephyrproject-rtos/hal_microchip
hal_nordic   modules/hal/nordic           248eadcacf976bbd27f1c0bc0dd3f11d8ec8657e https://github.com/zephyrproject-rtos/hal_nordic
hal_nuvoton  modules/hal/nuvoton          602db600cae5275ab0946de696a6068d769a6b3d https://github.com/zephyrproject-rtos/hal_nuvoton
hal_nxp      modules/hal/nxp              430b7b5317a691e186335fac375fa99050def582 https://github.com/zephyrproject-rtos/hal_nxp
hal_openisa  modules/hal/openisa          eabd530a64d71de91d907bad257cd61aacf607bc https://github.com/zephyrproject-rtos/hal_openisa
hal_quicklogic modules/hal/quicklogic       bad894440fe72c814864798c8e3a76d13edffb6c https://github.com/zephyrproject-rtos/hal_quicklogic
hal_realtek  modules/hal/realtek          4f8703eb110220e3a98c7e883f672a575679b9e8 https://github.com/zephyrproject-rtos/hal_realtek
hal_renesas  modules/hal/renesas          0164f2f515ad196674103f33cab10a7d547ce3cf https://github.com/zephyrproject-rtos/hal_renesas
hal_rpi_pico modules/hal/rpi_pico         09e957522da60581cf7958b31f8e625d969c69a5 https://github.com/zephyrproject-rtos/hal_rpi_pico
hal_sifli    modules/hal/sifli            faf0646bde76333644b9ec8ca156dd2affe1a9cf https://github.com/zephyrproject-rtos/hal_sifli
hal_silabs   modules/hal/silabs           6bde23d62ffd16347d1696ba15db92b070907828 https://github.com/zephyrproject-rtos/hal_silabs
hal_st       modules/hal/st               6d963459acecfd2f9748ab506385a3188d8768f0 https://github.com/zephyrproject-rtos/hal_st
hal_stm32    modules/hal/stm32            9325b43737ffca79ffe1af6300c90ffde98919da https://github.com/zephyrproject-rtos/hal_stm32
hal_tdk      modules/hal/tdk              60708f2c7bf078bc9cc3a7737ef955ec572c23e2 https://github.com/zephyrproject-rtos/hal_tdk
hal_telink   modules/hal/telink           4226c7fc17d5a34e557d026d428fc766191a0800 https://github.com/zephyrproject-rtos/hal_telink
hal_ti       modules/hal/ti               cc049020152585c4e968b83c084d230234b6d852 https://github.com/zephyrproject-rtos/hal_ti
hal_wch      modules/hal/wch              6dd313768b5f4cc69baeac4ce6e59f2038eb8ce5 https://github.com/zephyrproject-rtos/hal_wch
hal_wurthelektronik modules/hal/wurthelektronik  7c1297ea071d03289112eb24e789c89c7095c0a2 https://github.com/zephyrproject-rtos/hal_wurthelektronik
hal_xtensa   modules/hal/xtensa           3cc9e3a9360be5c96c956dce84064b85439b6769 https://github.com/zephyrproject-rtos/hal_xtensa
hostap       modules/lib/hostap           5af8b179632c602b8a05c34c74a50dda3d546eaa https://github.com/zephyrproject-rtos/hostap
liblc3       modules/lib/liblc3           48bbd3eacd36e99a57317a0a4867002e0b09e183 https://github.com/zephyrproject-rtos/liblc3
libmctp      modules/lib/libmctp          b97860e78998551af99931ece149eeffc538bdb1 https://github.com/zephyrproject-rtos/libmctp
libmetal     modules/hal/libmetal         91d38634d1882f0a2151966f8c5c230ce1c0de7b https://github.com/zephyrproject-rtos/libmetal
libsbc       modules/lib/libsbc           8e1beda02acb8972e29e6edbb423f7cafe16e445 https://github.com/zephyrproject-rtos/libsbc
littlefs     modules/fs/littlefs          8f5ca347843363882619d8f96c00d8dbd88a8e79 https://github.com/zephyrproject-rtos/littlefs
lora-basics-modem modules/lib/lora-basics-modem a8ddc544043e72807cf7db532478e1dda734ae7c https://github.com/zephyrproject-rtos/lora-basics-modem
loramac-node modules/lib/loramac-node     fb00b383072518c918e2258b0916c996f2d4eebe https://github.com/zephyrproject-rtos/loramac-node
lvgl         modules/lib/gui/lvgl         c016f72d4c125098287be5e83c0f1abed4706ee5 https://github.com/zephyrproject-rtos/lvgl
mbedtls      modules/crypto/mbedtls       c5b06d89c9c498d8fc8659ce31f7e53137b6270f https://github.com/zephyrproject-rtos/mbedtls
mcuboot      bootloader/mcuboot           234c66e66ee39c0f836a57ba805245534be332f2 https://github.com/zephyrproject-rtos/mcuboot
mipi-sys-t   modules/debug/mipi-sys-t     5a9d6055b62edc54566d6d0034d9daec91749b98 https://github.com/zephyrproject-rtos/mipi-sys-t
nanopb       modules/lib/nanopb           5499fd4c9a478f8139eeb07a82c3b4468d6067f7 https://github.com/zephyrproject-rtos/nanopb
net-tools    tools/net-tools              64d7acc661ae2772282570f21beab85d02f2f35c https://github.com/zephyrproject-rtos/net-tools
nrf_hw_models modules/bsim_hw_models/nrf_hw_models 0f0c43748111c65800c6920f1c0690676423a351 https://github.com/zephyrproject-rtos/nrf_hw_models
nrf_wifi     modules/lib/nrf_wifi         9f09f0785f9fc716514d8956a2a446021697400c https://github.com/zephyrproject-rtos/nrf_wifi
open-amp     modules/lib/open-amp         c30a6d8b92fcebdb797fc1a7698e8729e250f637 https://github.com/zephyrproject-rtos/open-amp
openthread   modules/lib/openthread       2bc7712f57af22058770d1ef131ad3da79a0c764 https://github.com/zephyrproject-rtos/openthread
percepio     modules/debug/percepio       132ed87d617578a6cb70a2443f43e117c315e0f0 https://github.com/zephyrproject-rtos/percepio
picolibc     modules/lib/picolibc         ca8b6ebba5226a75545e57a140443168a26ba664 https://github.com/zephyrproject-rtos/picolibc
psa-arch-tests modules/tee/tf-m/psa-arch-tests 941cd8436a2e0f1da9d8584b83a403930826899d https://github.com/zephyrproject-rtos/psa-arch-tests
segger       modules/debug/segger         7c843ea24b9b4f100c226bce0b4eb807e50a42ac https://github.com/zephyrproject-rtos/segger
tf-m-tests   modules/tee/tf-m/tf-m-tests  cde5b6ed540d3ff5a09564fded6b39b0a70ad3bf https://github.com/zephyrproject-rtos/tf-m-tests
trusted-firmware-a modules/tee/tf-a/trusted-firmware-a 0a29cac8fe0f7bdb835b469d9ea11b8e17377a92 https://github.com/zephyrproject-rtos/trusted-firmware-a
trusted-firmware-m modules/tee/tf-m/trusted-firmware-m e9ea674ed02e8ee00548f1bb994d52df23c8068d https://github.com/zephyrproject-rtos/trusted-firmware-m
uoscore-uedhoc modules/lib/uoscore-uedhoc   54abc109c9c0adfd53c70077744c14e454f04f4a https://github.com/zephyrproject-rtos/uoscore-uedhoc
zcbor        modules/lib/zcbor            9b07780aca6fb21f82a241ba386ad9b379809337 https://github.com/zephyrproject-rtos/zcbor
```