/* xor_rvv.h — 通用缓冲区 XOR 内核（RVV，e8m1）。逐字节等价。 */
#ifndef RVV_XOR_H
#define RVV_XOR_H
#include <riscv_vector.h>
#include <stddef.h>

static inline void rvv_xor_inplace (unsigned char *buf, const unsigned char *mask, size_t n)
{
  size_t i = 0;
  while (i < n) {
      size_t vl = __riscv_vsetvl_e8m1 (n - i);
      vuint8m1_t a = __riscv_vle8_v_u8m1 (buf + i, vl);
      vuint8m1_t b = __riscv_vle8_v_u8m1 (mask + i, vl);
      __riscv_vse8_v_u8m1 (buf + i, __riscv_vxor_vv_u8m1 (a, b, vl), vl);
      i += vl;
  }
}

static inline void rvv_xor_out (unsigned char *out, const unsigned char *in,
                                const unsigned char *in2, size_t n)
{
  size_t i = 0;
  while (i < n) {
      size_t vl = __riscv_vsetvl_e8m1 (n - i);
      vuint8m1_t a = __riscv_vle8_v_u8m1 (in + i, vl);
      vuint8m1_t b = __riscv_vle8_v_u8m1 (in2 + i, vl);
      __riscv_vse8_v_u8m1 (out + i, __riscv_vxor_vv_u8m1 (a, b, vl), vl);
      i += vl;
  }
}
#endif
