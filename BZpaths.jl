module BZpaths
    using Brillouin
    using LinearAlgebra
    using Bravais
    using CairoMakie
    include("kpaths.jl")
    export custom_path, kpath, plot_kpath, plot_observable_in_kpath
end
