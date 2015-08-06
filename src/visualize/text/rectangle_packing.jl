using GeometryTypes

type Node
    children::Vector{Node}
    area::Rectangle{Int}
end
Node(area::Rectangle) = Node(Node[], area)

isleaf(a::Node) = isempty(a.children)


function Base.push!(node::Node, area::Rectangle)
    if !isleaf(node)
        a = push!(node.children[1], area)
        a == nothing && return push!(node.children[2], area)
        return a
    end
    newarea = Node(area).area
    if newarea.w <= node.area.w && newarea.h <= node.area.h
        oax,oay,oaxw,oayh = node.area.x+newarea.w, node.area.y, xwidth(node.area), node.area.y + newarea.h
        nax,nay,naxw,nayh = node.area.x, node.area.y+newarea.h, xwidth(node.area), yheight(node.area)
        rax,ray,raxw,rayh = node.area.x, node.area.y, node.area.x+newarea.w, node.area.y+newarea.h
        
        push!(node.children, Node(Rectangle(oax, oay, oaxw-oax, oayh-oay)))
        push!(node.children, Node(Rectangle(nax,nay, naxw-nax,nayh-nay)))
        return Node(Rectangle(rax,ray,raxw-rax,rayh-ray))
    end
end

