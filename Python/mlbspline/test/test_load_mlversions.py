import warnings, unittest as ut
import numpy as np
from mlbspline import load


class TestLoadSplineWithMatlabVersions(ut.TestCase):
    def setUp(self):
        warnings.simplefilter('ignore', category=ImportWarning)
    def tearDown(self):
        pass
    def check1dspline(self, sp):
        self.assertEqual(sp['form'], 'B-', 'form not properly loaded')
        self.assertEqual(sp['dim'], 1, 'dim not properly loaded')
        self.assertTrue(np.array_equal(sp['number'], np.array([131])), 'number not properly loaded')
        self.assertTrue(np.array_equal(sp['order'], np.array([4])), 'order not properly loaded')
        self.assertEqual(sp['knots'].ndim, 1, 'knots loaded with wrong nesting')
        self.assertEqual(sp['knots'][0].shape, (135,), 'knots not all loaded')
        # spot check a few values in knots
        self.assertEqual(sp['knots'][0][0], 240, 'first knot incorrect value')
        self.assertEqual(sp['knots'][0][49], 334, 'fiftieth knot incorrect value')
        self.assertEqual(sp['knots'][0][134], 500, 'last knot incorrect value')
        self.assertEqual(sp['coefs'].ndim, 1, 'coefs not properly nested')
        self.assertEqual(sp['coefs'].shape, (131,), 'coefs not all loaded')
        # spot check a few coefs - precision is number of decimal points  shown minus power of 10
        self.assertAlmostEqual(sp['coefs'][0], 7.934961866962184e+03, 12, 'first coef value not equal')
        self.assertAlmostEqual(sp['coefs'][9], 5.008173328406900e+03, 12, 'tenth coef value not equal')
        self.assertAlmostEqual(sp['coefs'][130], -1.833688771741746e+04, 11, 'last coef value not equal')
    def test1dsplinev7(self):
        sp = load.loadSpline('spline1d_v7.mat')
        self.check1dspline(sp)
    def test1dsplinev73(self):
        sp = load.loadSpline('spline1d_v73.mat')
        self.check1dspline(sp)

if __name__ == '__main__':
    ut.main()

