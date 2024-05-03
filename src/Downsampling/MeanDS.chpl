/* Support for mean-downsampling of arrays */
module MeanDS {
  use Reflection;

  /*
    Downsample an array by taking the mean of groups of
    elements and storing the results in a smaller array.

    :arg a: the array to downsample. It's element type must support addition
            and division by an integer.
    :arg shape: the shape of the downsampled array. It must be the same rank
                as ``a`` and each of its dimensions must be smaller than the
                corresponding dimension of ``a``.

    :returns: an array of the provided shape, where each element is the mean
              of the corresponding group of elements in ``a``
  */
  proc meanDownsample(const ref a: [?d] ?t, shape: domain(?)): [shape] t throws
    where d.rank == shape.rank && isNumericType(t)
  {
    var ret: [shape] t;

    var factors: d.rank*int;
    for param i in 0..<d.rank do factors[i] = d.dim(i).size / shape.dim(i).size;

    for i in 0..<d.rank {
      if factors[i] <= 0 then throw new IllegalArgumentError(
        "cannot downsample array of shape: " + d.shape(i):string +
        " to shape: " + shape.shape(i):string
      );
    }

    for iidx in shape {
      const idx = if d.rank == 1 then (iidx,) else iidx;
      var aSlice: d.rank*range;
      for param i in 0..<d.rank {
        const order = idx[i] - shape.dim(i).low;

        const zbStart = order * factors[i],
              zbStop = (order+1) * factors[i];

        const start = d.dim(i).orderToIndex(zbStart),
              stop = if zbStop >= d.dim(i).size
                then d.dim(i).high + 1
                else d.dim(i).orderToIndex(zbStop);

        aSlice[i] = start..<stop;
      }

      ret[iidx] = mean(a, {(...aSlice)});
    }

    return ret;
  }

  private proc mean(const ref a: [?d] ?t, slice: domain(?)): t {
    var sum:t = 0, count = 0;
    for i in slice {
      sum += a[i];
      count += 1;
    }
    return sum / count;
  }
}
