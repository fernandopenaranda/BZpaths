"""
Generates a new KPath object with a user specified path over the high symmetry points of the point group
in kpath"""
custom_path(high_sym_path, kp::KPath) = KPath(kp.points, [high_sym_path], kp.basis, kp.setting)
# bravais vectors can be computed by dual_basis(lat_vectors)

"""
returns an evenly interpolated kpath of few than N points, given the lattice vectors and the symmetry 
point group (1-17 for the wallpaper 2d point groups) 18-230 for the 3d point groups.
Note that the dimensions of the lat_vectors has to be consistent with the dim of the point group.
"""
function kpath(lat_vectors, sgnum, N, high_sym_path::Vector = []; return_positions = false)
    kp = irrfbz_path(sgnum, lat_vectors)
    if isempty(high_sym_path) == true
        nothing
    else 
        kp = custom_path(high_sym_path, kp)
    end
    ks = interpolate(kp, N)
    if return_positions == false
        return cartesianize(ks)
    else
        tol = 1e-6
        idxs = Int[]
        V = collect(values(kp.points))
        count = 0
        for v in eachrow(V)
            matches = findall(r -> norm(r .- v) < tol, eachrow(ks))
            count+=1
            append!(idxs, matches)
        end
        return cartesianize(ks), idxs, high_sym_path
    end
end

"""
you can specify the line_path with vertices in the high symmetry momenta
but cannot use as vertices momenta not in the high_sym_path. To do
"""
function plot_kpath(lat_vectors, sgnum, N, high_sym_path::Vector = [])
    if length(lat_vectors[1]) == 3
        println("there is no method for plotting in 3d")
    else
        kp = irrfbz_path(sgnum, lat_vectors)
        if isempty(high_sym_path) == true
            nkp = kp
            lbl = kp.paths[1]
        else 
            lbl = high_sym_path
            nkp = custom_path(high_sym_path, kp)
        end
        ws = cartesianize(wignerseitz(dualbasis(Rs)))
        cartesianize!(nkp)
        kpoints = interpolate(nkp, N)
        fig = Figure()
        ax = Axis(fig[1,1], xlabel = "kx", ylabel = "ky")
        for verts in ws.verts
            scatter!(ax, verts, color = :blue, markersize =  15)
        end
        xs = []
        ys = []
  
        for t in nkp.paths[1]
            scatter!(ax, nkp.points[t], color = :black, markersize =  10)
            append!(xs, nkp.points[t][1])
            append!(ys, nkp.points[t][2])
        end
        lines!(ax, [k[1] for k in kpoints], [k[2] for k in kpoints], color = :black)
        # Add text labels
        for (x, y, lbl) in zip(xs, ys, lbl)
            text!(ax, string(lbl); position=(x+maximum(xs)/50, y+maximum(ys)/50), align=(:left, :bottom), fontsize=16)
        end


        fig
    end
end

"""
given a function of k, plot it wrt ks in a path
"""
function plot_observable_in_kpath(obs::Function, lat_vectors, sgnum::Int64, N, high_sym_path::Vector = [])
    if isempty(high_sym_path) == true
        kp = irrfbz_path(sgnum, lat_vectors)
        ks, pos, _ = kpath(lat_vectors, sgnum, N,  kp.paths[1]; return_positions = true)
        return plot_observable_in_kpath(obs, ks, pos, kp.paths[1])
    else
        ks, pos, _ = kpath(lat_vectors, sgnum, N, high_sym_path; return_positions = true)
        return plot_observable_in_kpath(obs, ks, pos, high_sym_path)
    end
end

function plot_observable_in_kpath(obs::Function, ks, pos::Vector, high_sym_momenta; xlab = "", ylims = nothing, xlims = nothing, color = :black)
    fig = Figure()
    ax = Axis(fig[1,1], xlabel = xlab, ylabel = "k")
    lines!(ax, [obs(k) for k in ks], color = color)
    ax.xticks = (sort(pos), string.(high_sym_momenta))
    if ylims == nothing
        nothing
    else
        ylims!(ax, ylims)
    end
    if xlims ==nothing
        nothing
    else  
        xlims!(ax, xlims)
    end

    fig
end


#= usage
1) Define the real space lattice vectors. They could be 3d or 2d
Rs = ([1.0, 0.0], [0, 1.0])

2) Specify the point group 1-17 for 2d 18 - 230 in 3d
sgnum = 10 # symmetry group number for the square 2d lattice

3) build the KPath object. 
kp = irrfbz_path(sgnum, Rs)

4) Note: kp will have custom k-paths along the high symmetry momenta 
coded in kp.paths. If you want custom paths within the BZ you can alter this struct by:
high_sym_path = [:Γ, :M, :X] # the vertices of the new path (symbols must be present in kp.paths)
new_kp = custom_path(high_sym_path, kp)

5) finally we interpolate evenly in these lines by:
N = 10 # number of kpoints
klist = cartesianize(interpolate(new_kp, N))
# Note: cartesianize is required to return klist in the cartesian basis and not in the bravais vectors lattice
=#