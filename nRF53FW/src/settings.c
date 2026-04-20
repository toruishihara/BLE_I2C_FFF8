#include <zephyr/settings/settings.h>
#include <zephyr/sys/printk.h>
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
