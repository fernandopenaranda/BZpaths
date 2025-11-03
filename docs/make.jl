using BZpaths
using Documenter

DocMeta.setdocmeta!(BZpaths, :DocTestSetup, :(using BZpaths); recursive=true)

makedocs(;
    modules=[BZpaths],
    authors="Fernando Peñaranda",
    sitename="BZpaths.jl",
    format=Documenter.HTML(;
        canonical="https://fernandopenaranda.github.io/BZpaths.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fernandopenaranda/BZpaths.jl",
    devbranch="main",
)
