from myleet import mypow
import math


def test_mypow():
    sol = mypow.Solution()
    assert sol.myPow(2, -2) == math.pow(2, -2)
