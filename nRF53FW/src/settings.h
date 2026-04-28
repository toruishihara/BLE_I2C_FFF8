#ifndef SETTINGS_H
#define SETTINGS_H

#include <zephyr/types.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/conn.h>
#include <zephyr/bluetooth/gatt.h>

extern const struct bt_gatt_service_static ble_svc;
extern uint8_t config_payload[20];

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

// ================================
// Command IDs
// ================================
typedef enum {
    CONFIG_CMD_READ_VALUE   = 0x11,
    CONFIG_CMD_READ_RESULT  = 0x12,
    CONFIG_CMD_WRITE_VALUE  = 0x13,
} config_cmd_t;

// ================================
// Config IDs
// ================================
typedef enum {
    CONFIG_ID_DEVICE_NAME              = 0xC0, // String
    CONFIG_ID_DEVICE_TIME_SEC          = 0xC1, // uint32_t (Unix time)
    CONFIG_ID_DEVICE_TIME_USEC         = 0xC2, // uint32_t (microseconds)
    CONFIG_ID_SEND_INTERVAL_SEC        = 0xC3, // uint32_t (seconds)
    CONFIG_ID_SEND_INTERVAL_USEC       = 0xC4, // uint32_t (microseconds)
    CONFIG_ID_POWER_OFF_TIMER_SEC      = 0xC5, // uint32_t (seconds)
} config_id_t;

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

ssize_t read_config(struct bt_conn *conn, const struct bt_gatt_attr *attr, void *buf, uint16_t len, uint16_t offset);

ssize_t write_config(struct bt_conn *conn, const struct bt_gatt_attr *attr, const void *buf, uint16_t len, uint16_t offset, uint8_t flags);

#endif /* SETTINGS_H */
