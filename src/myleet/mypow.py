class Solution:
    # POW2_0_32[n] == 2 ** n
    POW2_0_32 = (
        1,
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        256,
        512,
        1024,
        2048,
        4096,
        8192,
        16384,
        32768,
        65536,
        131072,
        262144,
        524288,
        1048576,
        2097152,
        4194304,
        8388608,
        16777216,
        33554432,
        67108864,
        134217728,
        268435456,
        536870912,
        1073741824,
        2147483648,
        4294967296,
    )

    def myPow_plus(self, x: float, n: int):
        """
        Calculate `x ** n` manually for `n` is positive.
        In case `n` is big, we try to calculate `x ** (2 ** p)` for some `p`
        and reuse them to reduce the computational cost.
        """
        POW2_0_32 = self.POW2_0_32
        T = type(x)

        # cache[m] == x ** m
        # where m is 2 ** p for some p
        cache = {0: T(1), 1: x, 2: x * x}

        def pow_x(big_n: int):
            max_c = -1
            residual_n = 0
            for c, (p, p_next) in enumerate(zip(POW2_0_32, POW2_0_32[1:])):
                if p <= big_n < p_next:
                    max_c = c
                    residual_n = big_n - p
                    break

            for c in range(max_c + 1):
                if POW2_0_32[c] in cache:
                    continue
                cache[POW2_0_32[c]] = cache[POW2_0_32[c - 1]] * cache[POW2_0_32[c - 1]]
            return cache[POW2_0_32[max_c]], residual_n

        r = 1
        r_ = 0
        while True:
            if n <= 4:
                break
            r_, n = pow_x(n)
            r *= r_

        # n should be very small
        for _ in range(n):
            r *= x
        return r

    def myPow(self, x: float, n: int) -> float:
        if n == 0:
            T = type(x)
            return T(1)
        else:
            abs_n: int = n if n > 0 else -n
            sgn_n: float = n / abs_n
            r = self.myPow_plus(x, abs_n)
            if sgn_n > 0:
                return r
            else:
                return 1 / r



