use<MCAD/regular_shapes.scad>
use<MCAD/fasteners/threads.scad> 

$fn = 64;
t = 3;
tubeT = 1.25;
tubeD = 26 + 2 * tubeT;
tubeH = 125;
tubeInR = (tubeD/2)*sqrt(3)/2;
topH = 10;
bottomH = 5;
topR = tubeD * 1.5;
outerR = topR + t + 0.5;

module starfinder_logo() {
  include<starfinder_logo.scad>;
}

module hexagon_vase(h, w, t) {
  hexagon_tube(h+t, w/2 + t, t);
  hexagon_tube(t, w/2 + t, w/2 + t/2);
}


//translate([30,0,0])
//hexagon_vase(125, 26, 1);

tubesP = [
  [0, 0, t],
  for (angle = [0 : 60 : 300])
    ([sin(angle), cos(angle), 0] * (tubeInR * 2 + t)) + [0, 0, t]
];

module tubes() {
  for (p = tubesP) {
    translate(p)
    hexagon_prism(tubeH,tubeD/2 + 0.25);
  }
}

module dice_tubes() {
  for (p = tubesP) {
    color(p == [0,0,t] ? "blue" : "white", 0.7)
    translate(p)
    difference() {
      hexagon_prism(tubeH, 27/2);
      translate([0,0,t])
      hexagon_prism(tubeH + t, 24/2);
    }
  }
}

module tubeHolderSolid() {
  difference() {
    union() {
      translate([0,0,tubeH - topH + t - 0.01])
      cylinder(r = topR, h = topH);
      hexagon_prism(tubeH, tubeD);
      translate([0, 0, bottomH])
      linear_extrude(height = bottomH, scale = 1/1.1)
        hexagon(tubeD * 1.1);
      hexagon_prism(bottomH, tubeD * 1.1);
    }
    rotate([0, 0, 30])
    translate([0, 0, bottomH * 2])
    hexagon_prism(tubeH - bottomH * 2 - topH, tubeD/2 + t*1.2);
    intersection() {
      rotate([0, 0, 30])
      translate([0, 0, bottomH])
      hexagon_prism(tubeH - bottomH - topH, tubeD/2 + t*1.2);
      translate([0, 0, bottomH * 2 + 0.01])
      mirror([0, 0, 1])
      linear_extrude(height = bottomH, scale = 0.5)
        hexagon(tubeD/2 + t*1.2);
    }
    translate([0, 0, t + 0.01])
    mirror([0, 0, 1])
    linear_extrude(height = t + 0.2, scale = 0.8)
      hexagon(tubeD/2);
  }
  intersection() {
    translate([-tubeD/4, -topR - t, tubeH - topH + t])
    cube([tubeD/2, (topR + t) * 2, topH]);
    cylinder(r = topR + t, h = tubeH + t - 0.01);
  }
}

module tread(isInternal = false) {
    difference(){ 
      color("darkslategrey")
      metric_thread(
          diameter = outerR * 2 + t + 0.2,
          pitch = t,
          length = topH,
          internal = isInternal,
          n_starts = 1);
      translate([0,0,-0.01])
      cylinder(r = topR + 0.6, h = topH + 0.02);
    }
}

module caseCylinder() {
  difference() {
    union () {
      color("darkslategrey")
      cylinder(r = outerR, h = tubeH + t);
      translate([0, 0, 0.02])
      tread();
      translate([0, 0, tubeH + t - topH - 0.02])
      tread();
    }
    translate([0,0,-0.01])
    cylinder(r = topR + 0.5, h = tubeH + t + 0.02);
    translate([-tubeD/4 - 0.5, -topR - 2*t, tubeH + t - topH - 0.5])
    cube([tubeD/2 + 1, (topR + 2*t) * 2, topH + 1]);
  }
}

module tubeHolder() {
  difference() {
    tubeHolderSolid();
    tubes();
  }
}

module bezel_disc(r, h, t) {
  hull() {
    cylinder(r = r, h = h);
    translate([0,0,t])
    cylinder(r = r + t, h = h - 2 * t);  
  }
}

// A centered box with bezels.
module bezel_box(size, t) {
  translate(-[size[0], size[1], -2*t]/2)
  hull() {
    translate([-t, 0, 0])
    cube(size + [2*t,0,0]);
    translate([0, -t, 0])
    cube(size + [0,2*t,0]);
    translate([0, 0, -t])
    cube(size + [0,0,2*t]);
  }
}

module cap() {
  color("grey")
  difference() {
    translate([0, 0, -t - 0.01]) {
      bezel_disc(r = outerR + t, h = topH + t, t = t);
      intersection() {
        bezel_disc(outerR + 2*t, topH + t, t);
        for (angle = [0 : 60 : 359]) {
          rotate([0, 0, angle])
          bezel_box([8*t, outerR * 2 + 10*t, topH - t], t);
        }
      }
    }
    tread(isInternal = true);
    translate([0,0,-0.02])
    cylinder(r = topR + 0.61, h = topH + 0.04);
  }
}

module logo() {
  scale([3.7, 3.7, t + 0.1])
  starfinder_logo();
  translate([0,0,-0.01])
  cylinder(r = topR, h = 0.25);
}

module cap_logo() {
  difference() {
    translate([0,0,t])
    rotate([180, 0, 0])
    translate([0, 0, t + 0.02])
    cap();
    color("grey")
    minkowski() {
      scale([3.7, 3.7, t])
      starfinder_logo();
      translate([-0.25, -0.25, 0])
      cube([0.5,0.5, 0.1]);
    }
    translate([0,0,-0.01])
    cylinder(r = topR, h = 0.25);
  }
}

tubeHolder();
caseCylinder();
//cap();
//translate([110, 0, 0])
//logo();
translate([110, 0, 0])
cap_logo();
dice_tubes();
