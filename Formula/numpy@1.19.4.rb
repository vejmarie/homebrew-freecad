class NumpyAT1194 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/c5/63/a48648ebc57711348420670bb074998f79828291f68aebfff1642be212ec/numpy-1.19.4.zip"
  sha256 "141ec3a3300ab89c7f2b0775289954d193cc8edb621ea05f99db9cb181530512"
  license "BSD-3-Clause"
  head "https://github.com/numpy/numpy.git"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "d8f8547ed37a4744bcff3a20b2dd8a0cff6ea2232ed2dd97de4a67345d822aee" => :big_sur
  end

  depends_on "freecad/freecad/cython@0.29.21" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "openblas"
  depends_on "freecad/freecad/python3.9"

  # Upstream fix for Apple Silicon, remove in next version
  # https://github.com/numpy/numpy/pull/17906
  patch do
    url "https://github.com/numpy/numpy/commit/1ccb4c6d.patch?full_index=1"
    sha256 "7777fa6691d4f5a8332538b634d4327313e9cf244bb2bbc25c64acfb64c92602"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    version = Language::Python.major_minor_version Formula["freecad/freecad/python3.9"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", Formula["freecad/freecad/cython@0.29.21"].opt_libexec/"lib/python#{version}/site-packages"

    system Formula["freecad/freecad/python3.9"].opt_bin/"python3", "setup.py",
      "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
      "install", "--prefix=#{prefix}",
      "--single-version-externally-managed", "--record=installed.txt"
  end

  test do
    system Formula["freecad/freecad/python3.9"].opt_bin/"python3", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end