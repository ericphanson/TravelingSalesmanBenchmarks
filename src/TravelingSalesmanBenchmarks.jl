module TravelingSalesmanBenchmarks

using Weave, Pkg, IJulia, InteractiveUtils, Markdown

repo_directory = normpath(joinpath(@__DIR__,".."))
args = Dict("repo_directory" => repo_directory);

function weave_file(folder,file,build_list=(:script,:html,:notebook))
  println("File: $file")
  tmp = joinpath(repo_directory,"benchmarks",folder,file)
  args = Dict{Symbol,String}(:folder=>folder,:file=>file, :repo_directory=>repo_directory)
  if :script ∈ build_list
    println("Building Script")
    dir = joinpath(repo_directory,"script",folder)
    isdir(dir) || mkdir(dir)
    tangle(tmp;out_path=dir)
  end
  if :html ∈ build_list
    println("Building HTML")
    dir = joinpath(repo_directory,"html",folder)
    isdir(dir) || mkdir(dir)
    weave(tmp,doctype = "md2html",out_path=dir,args=args)
  end
  if :pdf ∈ build_list
    println("Building PDF")
    dir = joinpath(repo_directory,"pdf",folder)
    isdir(dir) || mkdir(dir)
    weave(tmp,doctype="md2pdf",out_path=dir,args=args)
  end
  if :github ∈ build_list
    println("Building Github Markdown")
    dir = joinpath(repo_directory,"markdown",folder)
    isdir(dir) || mkdir(dir)
    weave(tmp,doctype = "github",out_path=dir,args=args)
  end
  if :notebook ∈ build_list
    println("Building Notebook")
    dir = joinpath(repo_directory,"notebook",folder)
    isdir(dir) || mkdir(dir)
    Weave.convert_doc(tmp,joinpath(dir,file[1:end-4]*".ipynb"))
  end
end

function weave_all()
  for folder in readdir(joinpath(repo_directory,"benchmarks"))
    folder == "test.jmd" && continue
    weave_folder(folder)
  end
end

function weave_folder(folder)
  for file in readdir(joinpath(repo_directory,"benchmarks",folder))
    endswith(file, ".jmd") || continue
    println("Building $(joinpath(folder,file))")
    try
      weave_file(folder,file)
    catch e
      throw(e)
    end
  end
end

function bench_footer(folder=nothing, file=nothing)
    display(md"""
    ## Appendix

    These benchmarks are a part of the TravelingSalesmanBenchmarks.jl repository, found at: <https://github.com/ericphanson/TravelingSalesmanBenchmarks.jl>, based on the `weave` branch of [DiffEqBenchmarks](https://github.com/JuliaDiffEq/DiffEqBenchmarks.jl/tree/weave).
    """)
    if folder !== nothing && file !== nothing
        display(Markdown.parse("""
        To locally run this tutorial, do the following commands:
        ```
        using TravelingSalesmanBenchmarks
        TravelingSalesmanBenchmarks.weave_file("$folder","$file")
        ```
        """))
    end
    display(md"Computer Information:")
    vinfo = sprint(InteractiveUtils.versioninfo)
    display(Markdown.parse("""
    ```
    $(vinfo)
    ```
    """))

    ctx = Pkg.API.Context()
    pkgs = Pkg.Display.status(Pkg.API.Context(), use_as_api=true);

    display(md"""
    Package Information:
    """)

    io = IOBuffer()
    for pkg in pkgs
        ver = pkg.new.ver === nothing ? "" : pkg.new.ver
        println(io, "[$(pkg.uuid)] $(pkg.name) $ver")
    end
    proj = String(take!(io))
    md = """
    ```
    Status: `$(ctx.env.project_file)`
    $(chomp(proj))
    ```
    """
    display(Markdown.parse(md))
end

function open_notebooks()
  Base.eval(Main, Meta.parse("import IJulia"))
  path = joinpath(repo_directory,"notebook")
  IJulia.notebook(;dir=path)
end

end # module
