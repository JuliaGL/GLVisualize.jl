# very bad, but simple implementation


drag_xy(drag_id) = drag_id[1]
cuttoff(x) = max(min(1f0, x), 0f0)
isclicked(x) = !isempty(x)
function vizzedit(x::RGBA, inputs)
  drag      = inputs[:mousedragdiff_objectid]
  mbutton_clicked = inputs[:mousebuttonspressed]

  vizz  = visualize(Rectangle(0,0,50,50), style=Cint(5))
  is_num(drag_id) = drag_id[2][1] == vizz.id
  slide_addition  = lift(drag_xy, filter(is_num, (Vec2f0(0), Vec(0,0), Vec(0,0)), drag))
  haschanged    = foldl((t0, t1) -> (t0[2]!=t1, t1), (false, slide_addition.value), slide_addition)
  haschanged    = lift(first, haschanged)
  slide_addition  = keepwhen(haschanged, Vec2f0(0), slide_addition)

  slide_addition  = lift(last, foldl(GLAbstraction.mousediff, (false, Vec2f0(0), Vec2f0(0)), ## (Note 2)
                  lift(isclicked, mbutton_clicked), slide_addition))

  color = foldl(x, lift(/,slide_addition, 1000.0f0), mbutton_clicked) do v0, addition, mpress
    if length(mpress) == 1
      if mpress == IntSet(1) # leftclick changes blue+trans
        return RGBA{Float32}(v0.r, v0.g, cuttoff(v0.b-addition.x), cuttoff(v0.a-addition.y))
      elseif mpress == IntSet(0)
        return RGBA{Float32}(cuttoff(v0.r-addition.x), cuttoff(v0.g-addition.y), v0.b, v0.a)
      end
    end
    v0
  end
  vizz[:color] = color
  return color, vizz
end
