include<MCAD/regular_shapes.scad>

module hexagon_vase(h, w, t) {
  hexagon_tube(h+t, w/2 + t, t);
  hexagon_tube(t, w/2 + t, w/2 + t/2);
}


hexagon_vase(125, 26, 1);