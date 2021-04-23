
#include "mmps.h"
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>

inline
static size_t min(size_t lhs, size_t rhs)
{
    return lhs < rhs ? lhs : rhs;
}
struct mmps_t *mmps_init(const char *filename, size_t size, size_t ext_size)
{
    struct mmps_t *p = NULL;
    size = is_power_of_2(size) ? size : roundup_pow_of_two(size);
    int fd = open(filename, O_RDWR | O_CREAT, 0666);
    if (fd < 0) return NULL;
    do {
        
        // 改变文件大小为参数需要的大小
        if (ftruncate(fd, size + sizeof(struct mmps_t) + ext_size) != 0) break;
        //判断IO是否同步成功
        if (fsync(fd)) break;
        
        p = (struct mmps_t *)mmap(NULL, size + sizeof(struct mmps_t) + ext_size, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fd, 0);
        if (p == NULL) break;
        p->size = size;
        p->ext_size = ext_size;
        // msync(p, sizeof(struct mmps_t), MS_SYNC);
    } while (0);
    close(fd);
    return p;
}
inline
void mmps_free(struct mmps_t *mmps)
{
    if (mmps != NULL) {
        munmap(mmps, mmps->size + sizeof(struct mmps_t) + mmps->ext_size);
    }
}
inline
//实际更新扩展进程sampleBuffer>>DATA数据的接口，支持字节流传输
size_t mmps_put(struct mmps_t *mmps, const void *data, size_t len)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    len = min(len, mmps->size - mmps->in + mmps->out);
    size_t l = min(len, mmps->size - (mmps->in & (mmps->size - 1)));
    memcpy(buffer + (mmps->in & (mmps->size - 1)), data, l);
    memcpy(buffer, data + l, len - l);
    mmps->in += len;
    return len;
}
inline
size_t mmps_get(struct mmps_t *mmps, void *data, size_t len)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    len = min(len, mmps->in - mmps->out);
    size_t l = min(len, mmps->size - (mmps->out & (mmps->size - 1)));
    memcpy(data, buffer + (mmps->out & (mmps->size - 1)), l);
    memcpy(data + l, buffer, len - l);
    mmps->out += len;
    return len;
}
inline
struct mmps_data_t *mmps_data_snapshot_push(struct mmps_t *mmps, size_t size)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    size += sizeof(struct mmps_data_t) + sizeof(size_t);
    if (mmps_space(mmps) < size) return NULL;
    struct mmps_data_t *mmps_data = buffer + (mmps->in & (mmps->size - 1));
    mmps_data->size = size;
    *(size_t *)((void *)mmps_data + size - sizeof(size_t)) = mmps->in;
    return mmps_data;
}
inline
void mmps_data_snapshot_sync(struct mmps_t *mmps, struct mmps_data_t *data)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    size_t l = min(data->size, mmps->size - (mmps->in & (mmps->size - 1)));
    memcpy(buffer, (const char *)data + l, data->size - l);
    mmps->in += data->size;
}
inline
struct mmps_data_t *mmps_data_snapshot_pull(struct mmps_t *mmps)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    if (mmps_size(mmps) == 0) return NULL;
    mmps->out = *(size_t *)(buffer + ((mmps->in - sizeof(size_t)) & (mmps->size - 1)));
    return buffer + (mmps->out & (mmps->size - 1));
}
/* alloc on mmps -- no copy */
inline
struct mmps_data_t *mmps_data_alloc(struct mmps_t *mmps, size_t size)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    size += sizeof(struct mmps_data_t);
    if (mmps_space(mmps) < size) return NULL;
    struct mmps_data_t *mmps_data = buffer + (mmps->in & (mmps->size - 1));
    mmps_data->size = size;
    return mmps_data;
}

inline
void mmps_data_flush(struct mmps_t *mmps, struct mmps_data_t *data)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    size_t l = min(data->size, mmps->size - (mmps->in & (mmps->size - 1)));
    memcpy(buffer, (const char *)data + l, data->size - l);
    mmps->in += data->size;
}

inline
struct mmps_data_t *mmps_data_point(struct mmps_t *mmps)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    if (mmps_size(mmps) == 0) {
        return NULL;
    }
    return buffer + (mmps->out & (mmps->size - 1));
}

inline
void mmps_data_free(struct mmps_t *mmps, struct mmps_data_t *data)
{
    mmps->out += data->size;
}


inline
static size_t mmps_commit(struct mmps_t *mmps, const void *data, size_t len, size_t pos)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    size_t l = min(len, mmps->size - ((mmps->in + pos) & (mmps->size - 1)));
    memcpy(buffer + ((mmps->in + pos) & (mmps->size - 1)), data, l);
    memcpy(buffer, (const char *)data + l, len - l);
    return pos + len;
}
size_t mmps_yuv_put(struct mmps_t *mmps, struct y_uv_data_t *y_uv_data, const void *data, size_t size)
{
    if (mmps_space(mmps) < size) return 0;
    size_t pos = 0;
    pos = mmps_commit(mmps, &size, sizeof(size), pos);
    pos = mmps_commit(mmps, y_uv_data, sizeof(struct y_uv_data_t), pos);
    pos = mmps_commit(mmps, data, size - sizeof(struct mmps_data_t) - sizeof(struct y_uv_data_t), pos);
    mmps->in += pos;
    return size;
}


void mmps_yuv_save_last_frame(struct mmps_t *mmps, struct y_uv_data_t *y_uv_data, const void *data, size_t size)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t) + mmps->size;
    *(size_t *)buffer = 0;
    memcpy(buffer + sizeof(size_t), &size, sizeof(size_t));
    memcpy(buffer + sizeof(size_t) * 2, y_uv_data, sizeof(struct y_uv_data_t));
    memcpy(buffer + sizeof(size_t) * 2 + sizeof(struct y_uv_data_t), data, size - sizeof(struct y_uv_data_t) - sizeof(struct mmps_data_t));
    *(size_t *)buffer = 1;
}

struct mmps_data_t * mmps_yuv_point_last_frame(struct mmps_t *mmps)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t) + mmps->size;
    if (*(size_t *)buffer == 1) {
        return buffer + sizeof(size_t);
    }
    return NULL;
}

size_t mmps_data_put(struct mmps_t *mmps, const struct mmps_data_t *mmps_data)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    if (mmps_space(mmps) < mmps_data->size) return 0;
    size_t len = mmps_data->size;
    size_t l = min(len, mmps->size - (mmps->in & (mmps->size - 1)));
    memcpy(buffer + (mmps->in & (mmps->size - 1)), mmps_data, l);
    memcpy(buffer, (const char *)mmps_data + l, len - l);
    mmps->in += len;
    return len;
}
size_t mmps_data_get(struct mmps_t *mmps, struct mmps_data_t **mmps_data)
{
    void *buffer = (unsigned char *)mmps + sizeof(struct mmps_t);
    if (mmps_size(mmps) == 0) {
        *mmps_data = NULL;
        return 0;
    }
    size_t mmps_data_size = 0;
    size_t hl = min(sizeof(size_t), mmps->size - (mmps->out & (mmps->size - 1)));
    memcpy(&mmps_data_size, buffer + (mmps->out & (mmps->size - 1)), hl);
    memcpy((char *)&mmps_data_size + hl, buffer, sizeof(size_t) - hl);
    *mmps_data = (struct mmps_data_t *)malloc(mmps_data_size);
    size_t len = mmps_data_size;
    size_t l = min(len, mmps->size - (mmps->out & (mmps->size - 1)));
    memcpy(*mmps_data, buffer + (mmps->out & (mmps->size - 1)), l);
    memcpy((char *)*mmps_data + l, buffer, len - l);
    mmps->out += len;
    return len;
}

inline
size_t mmps_size(struct mmps_t *mmps)
{
    return mmps->in - mmps->out;
}
inline
size_t mmps_space(struct mmps_t *mmps)
{
    return mmps->size - mmps_size(mmps);
}
inline
void mmps_clear(struct mmps_t *mmps)
{
    if (mmps != NULL) {
        mmps->in = mmps->out = 0;
    }
    // msync(mmps, sizeof(struct mmps_t), MS_SYNC);
}
inline
int is_power_of_2(size_t num)
{
    return !(num == 0) && !(num & (num - 1));
}
inline
size_t roundup_pow_of_two(size_t num)
{
    int x = 0;
    while (num) { num >>= 1; x++; }
    return 1UL << x;
}
inline
long getCurrentTimestamp(void)
{
    struct timeval tv;
    
    gettimeofday(&tv,NULL);
    
    return tv.tv_sec *1000 + tv.tv_usec / 1000;
}
