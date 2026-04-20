#ifndef SETTINGS_H
#define SETTINGS_H

#include <zephyr/types.h>

typedef enum {
    SENSOR_ID_TIMESTAMP              = 0x10, // UInt32, Unix time
    SENSOR_ID_TIMESTAMP_USEC        = 0x11, // UInt32, microsecond
    SENSOR_ID_TEMPERATURE           = 0x12, // float (4 bytes), Celsius
    SENSOR_ID_HUMIDITY              = 0x13, // float (4 bytes), percent
    SENSOR_ID_LIGHT_VISIBLE         = 0x14, // UInt16
    SENSOR_ID_LIGHT_UVA             = 0x15, // UInt16
    SENSOR_ID_LIGHT_UVB             = 0x16, // UInt16
    SENSOR_ID_LIGHT_UVC             = 0x17  // UInt16
} sensor_id_t;



/**
 * @brief Save an integer setting.
 * 
 * @param key The setting key (e.g., "app/my_int").
 * @param value The integer value to save.
 * @return 0 on success, negative errno on failure.
 */
int save_setting_int(const char *key, int value);

/**
 * @brief Load an integer setting.
 * 
 * @param key The setting key.
 * @param value Pointer to store the loaded value.
 * @return 0 on success, negative errno on failure.
 */
int load_setting_int(const char *key, int *value);

/**
 * @brief Save a string setting.
 * 
 * @param key The setting key.
 * @param value The string value to save.
 * @return 0 on success, negative errno on failure.
 */
int save_setting_str(const char *key, const char *value);

/**
 * @brief Load a string setting.
 * 
 * @param key The setting key.
 * @param dest Buffer to store the loaded string.
 * @param max_len Maximum length of the destination buffer.
 * @return 0 on success, negative errno on failure.
 */
int load_setting_str(const char *key, char *dest, size_t max_len);

#endif /* SETTINGS_H */
