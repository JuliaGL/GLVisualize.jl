# Splits a dictionary in two dicts, via a condition
function Base.split(condition::Function, associative::Associative)
    A = similar(associative)
    B = similar(associative)
    for (key, value) in associative
        if condition(key, value)
            A[key] = value
        else
            B[key] = value
        end
    end
    A, B
end

#creates methods to accept signals, which then gets transfert to an OpenGL target type
macro visualize_gen(input, target, S)
    esc(quote
        visualize(value::$input, s::$S, customizations=visualize_default(value, s)) =
            visualize($target(value), s, customizations)

        function visualize(signal::Signal{$input}, s::$S, customizations=visualize_default(signal.value, s))
            tex = $target(signal.value)
            lift(update!, Input(tex), signal)
            visualize(tex, s, customizations)
        end
    end)
end


# scalars can be uploaded directly to gpu, but not arrays
texture_or_scalar(x) = x
texture_or_scalar(x::Array) = Texture(x)
function texture_or_scalar{A <: Array}(x::Signal{A})
    tex = Texture(x.value)
    lift(update!, tex, x)
    tex
end

isnotempty(x) = !isempty(x)
AND(a,b) = a&&b


call(::Type{AABB}, a::GPUArray) = AABB{Float32}(gpu_data(a))
call{T}(::Type{AABB{T}}, a::GPUArray) = AABB{T}(gpu_data(a))



call(::Type{AABB}, a::GPUArray) = AABB(gpu_data(a))
call(::Type{AABB}, a::GPUArray) = AABB(gpu_data(a))

function GLVisualizeShader(shaders...; attributes...)
    shaders = map(shader -> load(joinpath(shaderdir(), shader)), shaders)
    TemplateProgram(shaders...;
        attributes...,  fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")],
        updatewhile=ROOT_SCREEN.inputs[:open], update_interval=1.0
    )
end

function default_boundingbox(main)
    main == nothing && return Input(AABB{Float32}(Vec3f0(0), Vec3f0(1)))
    Input(AABB{Float32}(main))
end
function assemble_std(main, dict, shaders...; boundingbox=default_boundingbox(main), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    std_renderobject(dict, program, boundingbox, primitive)
end

function assemble_instanced(main, dict, shaders...; boundingbox=default_boundingbox(main), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    instanced_renderobject(dict, length(main), program, boundingbox, primitive)
end

function assemble_instanced(main::GPUVector, dict, shaders...; boundingbox=default_boundingbox(main), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    instanced_renderobject(dict, main, program, boundingbox, primitive)
end


function y_partition(area, percent)
    amount = percent / 100.0
    p = lift(area) do r
        (Rectangle{Int}(r.x, r.y, r.w, round(Int, r.h*amount)),
            Rectangle{Int}(r.x, round(Int, r.h*amount), r.w, round(Int, r.h*(1-amount))))
    end
    return lift(first, p), lift(last, p)
end
function x_partition(area, percent)
    amount = percent / 100.0
    p = lift(area) do r
        (Rectangle{Int}(r.x, r.y, round(Int, r.w*amount), r.h ),
            Rectangle{Int}(round(Int, r.w*amount), r.y, round(Int, r.w*(1-amount)), r.h))
    end
    return lift(first, p), lift(last, p)
end

function collect_for_gl{T <: HomogenousMesh}(m::T)
    result = Dict{Symbol, Any}()
    attribs = attributes(m)
    @materialize! vertices, faces = attribs
    result[:vertices]   = GLBuffer(vertices)
    result[:faces]      = indexbuffer(faces)
    for (field, val) in attribs
        if field in [:texturecoordinates, :normals, :attribute_id]
            result[field] = GLBuffer(val)
        else
            result[field] = Texture(val)
        end
    end
    result
end

particle_grid_bb{T}(min_xy::Vec{2,T}, max_xy::Vec{2,T}, minmax_z::Vec{2,T}) = AABB{T}(Vec(min_xy..., minmax_z[1]), Vec(max_xy..., minmax_z[2]))
