/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/sensor.h>
#include <zephyr/sys/printk.h>
#include <zephyr/drivers/i2c.h>
#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/conn.h>
#include <zephyr/bluetooth/gatt.h>
#include <zephyr/bluetooth/hci.h>
#include <zephyr/settings/settings.h>
#include "settings.h"

#define APP_FW_VERSION "0.1.0"
#define I2C_NODE DT_NODELABEL(i2c1)
#define AS7331_ADDR 0x74

#define BT_UUID_SERVICE_VAL 0xFFF8
#define BT_UUID_DATA_CHAR_VAL    0xFFF9
#define BT_UUID_CONFIG_CHAR_VAL    0xFFFA

static struct bt_uuid_16 ble_svc_uuid = BT_UUID_INIT_16(BT_UUID_SERVICE_VAL);
static struct bt_uuid_16 ble_data_chr_uuid = BT_UUID_INIT_16(BT_UUID_DATA_CHAR_VAL);
static struct bt_uuid_16 ble_config_chr_uuid = BT_UUID_INIT_16(BT_UUID_CONFIG_CHAR_VAL);

// Bluetooth UV Service and Characteristic definitions would go here
static struct bt_conn *current_conn;
static bool notify_enabled;

static struct k_work_delayable adv_restart_work;

extern const struct bt_gatt_service_static ble_svc;

static int adv_start(void);

static void ccc_cfg_changed(const struct bt_gatt_attr *attr, uint16_t value)
{
	notify_enabled = (value == BT_GATT_CCC_NOTIFY);
	printk("Notify %s\n", notify_enabled ? "enabled" : "disabled");
}

static void connected(struct bt_conn *conn, uint8_t err)
{
	if (err) {
		printk("BLE connect failed (err %u)\n", err);
		return;
	}
	if (current_conn) {
		printk("Already connected, disconnecting new conn\n");
		bt_conn_disconnect(conn, BT_HCI_ERR_REMOTE_USER_TERM_CONN);
		return;
	}

	current_conn = bt_conn_ref(conn);
	printk("BLE connected\n");

	(void)bt_le_adv_stop();
	printk("Advertise stop\n");
}

static void disconnected(struct bt_conn *conn, uint8_t reason)
{
	printk("BLE disconnected (reason %u)\n", reason);
	notify_enabled = false;

	if (current_conn) {
		bt_conn_unref(current_conn);
		current_conn = NULL;
	}

	/* Restart advertising after 200 ms */
	k_work_reschedule(&adv_restart_work, K_MSEC(200));
}

BT_CONN_CB_DEFINE(conn_cb) = {
	.connected = connected,
	.disconnected = disconnected,
};

static uint8_t data_payload[20];
static uint8_t config_payload[20];

static ssize_t read_config(struct bt_conn *conn, const struct bt_gatt_attr *attr,
			 void *buf, uint16_t len, uint16_t offset)
{
	printk("read_config (len %u): ", len);
	for (int i = 0; i < len; i++) {
		printk("%02X ", ((uint8_t *)buf)[i]);
	}
	printk("\n");

	return bt_gatt_attr_read(conn, attr, buf, len, offset, config_payload,
				 sizeof(config_payload));
}

static ssize_t write_config(struct bt_conn *conn, const struct bt_gatt_attr *attr,
			 const void *buf, uint16_t len, uint16_t offset,
			 uint8_t flags)
{
	if (offset + len > sizeof(config_payload)) {
		return BT_GATT_ERR(BT_ATT_ERR_INVALID_OFFSET);
	}

	memcpy(config_payload + offset, buf, len);
	printk("Central write or ask config (len %u): ", len);
	for (int i = 0; i < len; i++) {
		printk("%02X ", ((uint8_t *)buf)[i]);
	}
	printk("\n");
	uint8_t cmd = config_payload[0];
	uint8_t id = config_payload[1];

	if (cmd == 0x11) {// Read value
		uint8_t payload_len = 0;
		uint8_t len = 0;
		config_payload[0] = 0x12; // Read result
		if (id == 0xc0) {
			// return device_name setting
			char device_name[32];
			load_setting_str("app/device_name", device_name, sizeof(device_name));
			printk("device_name: %s\n", device_name);
			len = strlen(device_name);
			config_payload[1] = id;
			config_payload[2] = len;
			memcpy(config_payload + 3, device_name, len);
			payload_len = 3 + len;
		} else if (id == 0xc3) {
			// return interval_seconds setting
			int interval_sec;
			len = 2;
			load_setting_int("app/interval_seconds", &interval_sec);
			config_payload[1] = id;
			config_payload[2] = len;
			config_payload[3] = (uint8_t)(interval_sec & 0xFF);
			config_payload[4] = (uint8_t)(interval_sec >> 8);
			payload_len = 5;
		}
		int err = bt_gatt_notify(conn, &ble_svc.attrs[4], config_payload, payload_len);
		if (err) {
			printk("notify err=%d\n", err);
		}
	}


    /* Optional: Save to flash whenever it's written */
    //save_setting_str("app/config", (char *)config_payload);

	return len;
}

BT_GATT_SERVICE_DEFINE(ble_svc,
	BT_GATT_PRIMARY_SERVICE(&ble_svc_uuid.uuid),
	BT_GATT_CHARACTERISTIC(&ble_data_chr_uuid.uuid,
			       BT_GATT_CHRC_NOTIFY,
			       BT_GATT_PERM_NONE,
			       NULL, NULL, data_payload),
	BT_GATT_CCC(ccc_cfg_changed,
		    BT_GATT_PERM_READ | BT_GATT_PERM_WRITE),
	BT_GATT_CHARACTERISTIC(&ble_config_chr_uuid.uuid,
			       BT_GATT_CHRC_READ | BT_GATT_CHRC_WRITE | BT_GATT_CHRC_NOTIFY,
			       BT_GATT_PERM_READ | BT_GATT_PERM_WRITE,
			       read_config, write_config, config_payload),
	BT_GATT_CCC(ccc_cfg_changed,
		    BT_GATT_PERM_READ | BT_GATT_PERM_WRITE),
);

/* Advertise service UUID so apps can filter */
static const struct bt_data ad[] = {
    BT_DATA_BYTES(BT_DATA_FLAGS, (BT_LE_AD_GENERAL | BT_LE_AD_NO_BREDR)),
    BT_DATA_BYTES(BT_DATA_UUID16_ALL, BT_UUID_16_ENCODE(BT_UUID_SERVICE_VAL)),
};

static const struct bt_data sd[] = {
	BT_DATA(BT_DATA_NAME_COMPLETE,
    CONFIG_BT_DEVICE_NAME,
    sizeof(CONFIG_BT_DEVICE_NAME) - 1),
};


static void adv_restart_work_fn(struct k_work *work)
{
	int err = adv_start();
	if (err) {
		printk("adv restart failed: %d\n", err);
	}
}

static int adv_start(void)
{
	int err;

	/* If already advertising, stop first (safe if not advertising) */
	(void)bt_le_adv_stop();

	err = bt_le_adv_start(BT_LE_ADV_CONN,
			      ad, ARRAY_SIZE(ad),
			      sd, ARRAY_SIZE(sd));
	if (err) {
		printk("Advertising failed (err %d)\n", err);
		return err;
	}

	printk("Advertising started\n");
	return 0;
}

static int ble_init(void)
{
	int err = bt_enable(NULL);
	if (err) {
		printk("bt_enable failed (err %d)\n", err);
		return err;
	}

	printk("bt_enable success\n");
	printk("BLE name: %s\n", bt_get_name());

	return adv_start();
}

static void send_data_notify(uint16_t uva, uint16_t uvb, uint16_t uvc)
{
	if (!current_conn || !notify_enabled) {
		return;
	}

	/* little-endian packing example */
	data_payload[0] = (uint8_t)(0x15);
	data_payload[1] = (uint8_t)(2);
	data_payload[2] = (uint8_t)(uva & 0xFF);
	data_payload[3] = (uint8_t)(uva >> 8);
	data_payload[4] = (uint8_t)(0x16);
	data_payload[5] = (uint8_t)(2);
	data_payload[6] = (uint8_t)(uvb & 0xFF);
	data_payload[7] = (uint8_t)(uvb >> 8);
	data_payload[8] = (uint8_t)(0x17);
	data_payload[9] = (uint8_t)(2);
	data_payload[10] = (uint8_t)(uvc & 0xFF);
	data_payload[11] = (uint8_t)(uvc >> 8);

	int err = bt_gatt_notify(current_conn, &ble_svc.attrs[1], data_payload, 12);
	if (err) {
		/* -ENOTCONN if disconnected, -EACCES if CCC off, etc */
		printk("notify err=%d\n", err);
	}
}

static void set_default_config()
{
	int rc;
	rc = save_setting_int("app/init", 1);
	rc = save_setting_int("app/interval_seconds", 10);
	rc = save_setting_str("app/device_name", "default");
	if (rc) {
		printk("Failed to save device name setting: %d\n", rc);
	}
}

int main(void)
{
    const struct device *i2c_dev;
    int ret;
	int err;

	printk("Boot ver %s\n", APP_FW_VERSION);
	err = settings_subsys_init();
	if (err) {
		printk("settings subsys initialization failed (err %d)\n", err);
	}
	err = settings_load();
	if (err) {
		printk("settings_load failed (err %d)\n", err);
	}

	int val;
	err = load_setting_int("app/init", &val);
	//if (val >= -999) {
		set_default_config();
		settings_load();
		char buf[32];
		err = load_setting_str("app/device_name", buf, sizeof(buf));
		printk("load_setting_str err=%d buf=%s\n", err, buf);
	//}

    i2c_dev = DEVICE_DT_GET(I2C_NODE);
    if (!device_is_ready(i2c_dev)) {
        printk("I2C device not ready\n");
        return 0;
    }
    printk("I2C device ready\n");

	k_work_init_delayable(&adv_restart_work, adv_restart_work_fn);

	if (ble_init() != 0) {
		printk("BLE init failed\n");
		return 0;
	}
    printk("BLE ready\n");

	// State check for AS7331
	uint8_t reg = 0x00;   // example ID register
	uint16_t state;
	ret = i2c_write_read(i2c_dev, AS7331_ADDR, &reg, 1, &state, 2);
    if (ret) {
        printk("I2C, AS7331_ADDR read failed: %d\n", ret);
        return 0;
    }
    printk("AS7331_ADDR Sensor reg = 0x%02X\n", reg);
	printk("AS7331_ADDR Sensor state = 0x%04X\n", state);

	uint8_t osr;

	// CONFIG + power-up AS7331
	osr = 0x02;
	i2c_reg_write_byte(i2c_dev, AS7331_ADDR, 0x00, osr);

	// (configure CREG registers here)

	int cnt = 0;
	while(1) {
		// MEASUREMENT + start
		osr = 0x83;
		i2c_reg_write_byte(i2c_dev, AS7331_ADDR, 0x00, osr);

		// Wait for measurement to complete
		int j = 0;
		for (j=0;j<100;++j) {
			k_msleep(10);
			ret = i2c_write_read(i2c_dev, AS7331_ADDR, &reg, 1, &state, 2);
			printk("AS7331_ADDR Sensor state = 0x%04X j=%d\n", state, j);
			if ((state & 0x0800) != 0) { // check NDATA bit on STATUS for measurement complete
				break;
			}
		}

		/* 3. Read UV data registers */
		uint8_t buf[6];

		int rc = i2c_burst_read(i2c_dev,
                        AS7331_ADDR,
                        0x02,   // MRES1
                        buf,
                        6);
		printk("i2c_burst_read=%02x %02x %02x %02x %02x %02x\n", buf[0], buf[1], buf[2], buf[3], buf[4], buf[5]);
		if (rc == 0) {
    		uint16_t uva = buf[0] | (buf[1] << 8);
    		uint16_t uvb = buf[2] | (buf[3] << 8);
    		uint16_t uvc = buf[4] | (buf[5] << 8);

			printk("UVA=%u UVB=%u UVC=%u wait=%d ms\n", uva, uvb, uvc, j*10);
			send_data_notify(uva, uvb, uvc);
		}
		int sleep_sec;
		load_setting_int("app/interval_seconds", &sleep_sec);
		k_sleep(K_SECONDS(sleep_sec));
		cnt ++;
	}
}
