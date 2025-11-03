using BZpaths
using Test

@testset "BZpaths.jl" begin
    Rs = ([1.0, 0.0], [0, 1.0])                 # Lattice vectors, can be 2d or 3d
    high_sym_line = [:Γ, :M, :X, :Γ]            # Custom k-path over high symmetry momenta
    sgnum = 10                                  # point group (10 = 2d square lattice)
    N = 100                                     # points in the k-mesh
    kp = kpath(Rs, sgnum, num_points)
end