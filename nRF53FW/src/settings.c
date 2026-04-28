#include <zephyr/settings/settings.h>
#include <zephyr/sys/printk.h>
#include <zephyr/bluetooth/att.h>
#include <string.h>
#include <errno.h>
#include "settings.h"

struct direct_load_ctx {
	const char *key;
	void *dest;
	size_t len;
	bool found;
};

static int direct_loader(const char *key, size_t len, settings_read_cb read_cb,
			  void *cb_arg, void *param)
{
	struct direct_load_ctx *ctx = (struct direct_load_ctx *)param;

	/* 
	 * Since we call settings_load_subtree_direct with the full key,
	 * any callback we receive is for our target. We ignore the 'key'
	 * string argument to remain compatible with all Zephyr backends.
	 */
	ssize_t read_len = read_cb(cb_arg, ctx->dest, ctx->len);
	if (read_len >= 0) {
		ctx->found = true;
		return 0;
	}

	return (int)read_len;
}

int save_setting_int(const char *key, int value)
{
	return settings_save_one(key, &value, sizeof(value));
}

int load_setting_int(const char *key, int *value)
{
	struct direct_load_ctx ctx = {
		.key = key,
		.dest = value,
		.len = sizeof(int),
		.found = false,
	};

	// We use settings_load_subtree to find the specific key
	int err = settings_load_subtree_direct(key, direct_loader, &ctx);
	if (err) {
		printk("Error loading setting '%s': %d\n", key, err);
		return err;
	}

	return ctx.found ? 0 : -ENOENT;
}

int save_setting_str(const char *key, const char *value)
{
	return settings_save_one(key, value, strlen(value));
}

int load_setting_str(const char *key, char *dest, size_t max_len)
{
	printk("load_setting_str called key=%s\n", key);
	struct direct_load_ctx ctx = {
		.key = key,
		.dest = dest,
		.len = max_len - 1, // Leave space for null terminator
		.found = false,
	};

	memset(dest, 0, max_len);

	int err = settings_load_subtree_direct(key, direct_loader, &ctx);
	if (err) {
		printk("Error loading setting '%s': %d\n", key, err);
		return err;
	}

	return ctx.found ? 0 : -ENOENT;
}

ssize_t read_config(struct bt_conn *conn, const struct bt_gatt_attr *attr,
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

ssize_t write_config(struct bt_conn *conn, const struct bt_gatt_attr *attr,
			 const void *buf, uint16_t len, uint16_t offset,
			 uint8_t flags)
{
	if (offset + len > sizeof(config_payload)) {
		return BT_GATT_ERR(BT_ATT_ERR_INVALID_OFFSET);
	}

	memcpy(config_payload + offset, buf, len);
	printk("central read/write config (len %u): ", len);
	for (int i = 0; i < len; i++) {
		printk("%02X ", ((uint8_t *)buf)[i]);
	}
	printk("\n");
	uint8_t cmd = config_payload[0];
	uint8_t id = config_payload[1];

	if (cmd == CONFIG_CMD_READ_VALUE) {
		uint8_t payload_len = 0;
		uint8_t len = 0;
		config_payload[0] = CONFIG_CMD_READ_RESULT;
		if (id == CONFIG_ID_DEVICE_NAME) {
			// return device_name setting
			char device_name[32];
			load_setting_str("app/device_name", device_name, sizeof(device_name));
			printk("device_name: %s\n", device_name);
			len = strlen(device_name);
			config_payload[1] = id;
			config_payload[2] = len;
			memcpy(config_payload + 3, device_name, len);
			payload_len = 3 + len;
		} else if (id == CONFIG_ID_SEND_INTERVAL_SEC) {
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

	if (cmd == CONFIG_CMD_WRITE_VALUE) {
		uint8_t payload_len = config_payload[2];

		if (id == CONFIG_ID_DEVICE_NAME) {
			settings_save_one("app/device_name", config_payload + 3, payload_len);

			// test only code
			char tmp[32];
			load_setting_str("app/device_name", tmp, sizeof(tmp));
			printk("new device_name: %s\n", tmp);

		}
	}

	return len;
}
