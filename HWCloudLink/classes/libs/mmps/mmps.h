#ifndef MMPS_H
#define MMPS_H
#include "string.h"
struct mmps_t {
    volatile size_t          size;              /* the size of the allocated buffer */
    volatile size_t          ext_size;
    volatile size_t          in;                /* data is added at offset (in % size) */
    volatile size_t          out;               /* data is extracted from off. (out % size) */
    volatile double          app_timestamp;     /* the timestamp of main app */
    volatile double          exc_timestamp;     /* the timestamp of extension */
};

struct mmps_data_t {
    size_t          size;         /* HEADER + DATA SIZE */
    unsigned char   data[0];
};

struct y_uv_data_t {
    size_t angle;
    size_t width;
    size_t height;
    size_t y_size;
    size_t uv_size;
};

struct mmps_t *mmps_init(const char *filename, size_t size, size_t ext_size);

void mmps_free(struct mmps_t *mmps);

struct mmps_status_t *mmps_status_point(struct mmps_t * mmps);
/* 注意事项 : 音视频传输需要创建不同的两个 mmps 实例 */

/* 音频数据 使用以下两个接口 */
size_t mmps_put(struct mmps_t *mmps, const void *data, size_t len);

size_t mmps_get(struct mmps_t *mmps, void *data, size_t len);

/* 三个接口 0 延迟 */
struct mmps_data_t *mmps_data_snapshot_push(struct mmps_t *mmps, size_t size);

void mmps_data_snapshot_sync(struct mmps_t *mmps, struct mmps_data_t *data);

struct mmps_data_t *mmps_data_snapshot_pull(struct mmps_t *mmps);

/* 视频数据帧 使用以下四个接口 */
struct mmps_data_t *mmps_data_alloc(struct mmps_t *mmps, size_t size);

void mmps_data_flush(struct mmps_t *mmps, struct mmps_data_t *data);

struct mmps_data_t *mmps_data_point(struct mmps_t *mmps);

void mmps_data_free(struct mmps_t *mmps, struct mmps_data_t *data);


size_t mmps_data_put(struct mmps_t *mmps, const struct mmps_data_t *mmps_data);

size_t mmps_data_get(struct mmps_t *mmps, struct mmps_data_t **mmps_data);

size_t mmps_yuv_put(struct mmps_t *mmps, struct y_uv_data_t *y_uv_data, const void *data, size_t size);

void mmps_yuv_save_last_frame(struct mmps_t *mmps, struct y_uv_data_t *y_uv_data, const void *data, size_t size);

struct mmps_data_t *mmps_yuv_point_last_frame(struct mmps_t *mmps);
/* --------------- */
size_t mmps_size(struct mmps_t *mmps);

size_t mmps_space(struct mmps_t *mmps);

void mmps_clear(struct mmps_t *mmps);

int is_power_of_2(size_t num);

size_t roundup_pow_of_two(size_t num);

long getCurrentTimestamp(void);

#endif // !MMPS_H
