using GLVisualize, NPZ

volume = npzread("mri.npz")["data"]

volume = volume./256f0

view(visualize(volume))

renderloop()