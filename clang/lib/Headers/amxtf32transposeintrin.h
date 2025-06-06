/*===--------- amxtf32transposeintrin.h - AMX-TF32 and AMX-TRANSPOSE --------===
 *
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 *===------------------------------------------------------------------------===
 */
#ifndef __IMMINTRIN_H
#error                                                                         \
    "Never use <amxtf32transposeintrin.h> directly; include <immintrin.h> instead."
#endif // __IMMINTRIN_H

#ifndef __AMX_TF32TRANSPOSEINTRIN_H
#define __AMX_TF32TRANSPOSEINTRIN_H
#ifdef __x86_64__

#define __DEFAULT_FN_ATTRS_TF32_TRANSPOSE                                      \
  __attribute__((__always_inline__, __nodebug__,                               \
                 __target__("amx-tf32,amx-transpose")))

/// \code
/// void _tile_tmmultf32ps(constexpr int srcdst, constexpr int a, \
///                        constexpr int b);
/// \endcode
///
/// This intrinsic corresponds to the <c> TTMMULTF32PS </c> instruction.
///
/// \param srcdst
/// 	The destination tile. Max size is 1024 Bytes.
/// \param a
/// 	The 1st source tile. Max size is 1024 Bytes.
/// \param b
/// 	The 2nd source tile. Max size is 1024 Bytes.
///
/// \code{.operation}
/// DEFINE zero_lower_mantissa_bits_fp32(x[31:0]) {
/// 	dword[12:0] := 0
/// 	dword[31:13] := x[31:13]
/// 	return dword
/// }
///
/// DEFINE silence_snan_fp32(x[31:0]) {
/// 	IF (x.exponent == 255 and x.fraction != 0 and x.fraction[22] == 0)
/// 		x.fraction[22] := 1
/// 	return x
/// }
///
/// elements_dest:= srcdst.colsb/4
///
/// FOR m := 0 TO (srcdst.rows-1)
/// 	tmp[511:0] := 0
/// 	FOR k := 0 TO (a.rows-1)
/// 		FOR n := 0 TO (elements_dest-1)
/// 			a1e := silence_snan_fp32(a.row[k].fp32[m])
/// 			a2e := silence_snan_fp32(b.row[k].fp32[n])
/// 			s1e := zero_lower_mantissa_bits_fp32(a1e)
/// 			s2e := zero_lower_mantissa_bits_fp32(a2e)
/// 			tmp.fp32[n] += s1e * s2e
/// 		ENDFOR
/// 	ENDFOR
///
/// 	FOR n := 0 TO (elements_dest-1)
/// 		tmp.fp32[n] += srcdst.row[m].fp32[n]
/// 	ENDFOR
///	write_row_and_zero(srcdst, m, tmp, srcdst.colsb)
///
/// ENDFOR
///
/// zero_upper_rows(srcdst, srcdst.rows)
/// zero_tileconfig_start()
/// \endcode
#define _tile_tmmultf32ps(srcdst, a, b)                                        \
  __builtin_ia32_ttmmultf32ps((srcdst), (a), (b))

// dst = m x n (srcdest), src1 = k x m, src2 = k x n
static __inline__ _tile1024i __DEFAULT_FN_ATTRS_TF32_TRANSPOSE
_tile_tmmultf32ps_internal(unsigned short m, unsigned short n, unsigned short k,
                           _tile1024i dst, _tile1024i src1, _tile1024i src2) {
  return __builtin_ia32_ttmmultf32ps_internal(m, n, k, dst, src1, src2);
}

/// Compute transpose and do Matrix Multiplication of src0 and src1, and then do
/// Matrix Plus with dst. All the calculation is base on float32 but with the
/// lower 13-bit set to 0.
///
/// \headerfile <immintrin.h>
///
/// This intrinsic corresponds to the <c> TTMMULTF32PS </c> instruction.
///
/// \param dst
///    The destination tile. Max size is 1024 Bytes.
/// \param src0
///    The 1st source tile. Max size is 1024 Bytes.
/// \param src1
///    The 2nd source tile. Max size is 1024 Bytes.
__DEFAULT_FN_ATTRS_TF32_TRANSPOSE
static void __tile_tmmultf32ps(__tile1024i *dst, __tile1024i src0,
                               __tile1024i src1) {
  dst->tile = _tile_tmmultf32ps_internal(src0.row, src1.col, src0.col,
                                         dst->tile, src0.tile, src1.tile);
}

#endif // __x86_64__
#endif // __AMX_TF32TRANSPOSEINTRIN_H
