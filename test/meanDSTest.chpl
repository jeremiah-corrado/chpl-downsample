use UnitTest;
use Downsampling.MeanDS;

const aDoms = (
  {0..<4},
  {0..<4, 0..<4},
  {1..4},
  {1..4, 1..4}
);

const bDoms = (
  {1..2},
  {0..<2, 1..2},
  {0..<2},
  {0..<2, 0..<2}
);

var x: [0..<2, 0..<2] real;
x[0, 0] = 5.0;
x[0, 1] = 9.0;
x[1, 0] = 21.0;
x[1, 1] = 25.0;

const results = (
  [1.0, 5.0],
  x,
  [1.0, 5.0],
  x
);

proc testMeanDS(test: borrowed Test) throws {
  for param i in 0..<aDoms.size {
    const ad = aDoms[i];
    var a: [ad] real;


    for ii in 0..<ad.size do
      a[ad.orderToIndex(ii)] = 2*ii:real;
    writeln(a);

    var b = meanDownsample(a, bDoms[i]);

    writeln(b);

    for (bi, ii) in zip(bDoms[i], results[i].domain) do
      test.assertTrue(abs(b[bi] - results[i][ii]) < 1e-10);
  }
}

proc testBadArg(test: borrowed Test) throws {
  const a: [0..<4] real;

  try {
    meanDownsample(a, {1..10});
  } catch e: IllegalArgumentError {
    test.assertEqual(e.message(), "cannot downsample array of shape: 4 to shape: 10");
  } catch e {
    test.assertTrue(false);
  }
}

UnitTest.main();
