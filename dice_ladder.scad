include<hinge.scad>

sideL = 41;
thick = 3;
bendR = thick * 2;
e = 0.1;
$fn = 50;
barL = thick * 1.5;

module bend(angle = 60, rr = bendR, h = thick) {
  translate([0, rr + thick, 0])
  rotate([0, 0, -90])
  rotate_extrude(angle = angle, convexity = 10)
  translate([rr, 0])
  square([thick, h]);
}

module slantedBend(angle = 60, rr = bendR) {
  translate([0, rr + thick, 0])
  rotate([0, 0, -90])
  rotate_extrude(angle = angle, convexity = 10)
  translate([rr, 0])
  hull() {
    square([thick, thick * 2/3]);
    square([thick * 2/3, thick]);
  }
}

module aSide(h = thick) {
  blip = 1/sin(60) * bendR;
  translate([-(sideL - blip)/2, 0, 0]) {
    cube([sideL - blip, thick, h]);
    translate([sideL - blip, 0 ,0])
    bend(60, bendR, h);
  }
}

module ring(h = thick) {
  for(a = [0 : 60 : 359]) {
    rotate([0, 0, a])
    translate([0, -thick-sideL * sqrt(3)/2, 0])
    aSide(h);
  }
}



module dualStub(dd = thick) {
  translate([0, -thick, 0])
  for (i = [0, 1]) {
    mirror([i, 0, 0]) {
      hull() {
        translate([thick/2, 0, 0])
        hull() {
          cube([thick * 2 /3, thick, thick]);
          cube([thick,thick, thick * 2/ 3]);
        }
        
        translate([thick/2, thick, dd/2])
        rotate([0, 90, 0]) {
          cylinder(r = dd/2, h = thick * 2/3);
          translate([0,0,thick * 2/3])
          cylinder(r1 = dd/2, r2 = dd/2/3, h = thick/3);
        }
      }      
      translate([thick/2, thick, dd * 0.5])
      rotate([0, -90, 0])
      cylinder(r1 = dd * 0.45, r2 = 0, h = thick * 0.4);
    }
  }
}

module singleStub(dd = thick) {
  stubGap = 0.2;
  translate([0, -thick*1/2 + 0*dd/2, 0])
  difference() {
    union() {
      translate([-thick/2 + stubGap, thick/2, 0])
      cube([thick - 2*stubGap, thick * 1, thick]);
      translate([thick/2 - stubGap, thick/2, dd/2])
      rotate([0,-90,0])
      cylinder(r = dd/2, h=thick - stubGap*2);
    }
    for (i = [0, 1]) {
      mirror([i, 0, 0])
      translate([thick/2 - 0.09, thick/2, dd * 0.5])
      rotate([0, -90, 0])
      cylinder(r1 = dd / 2, r2 = 0, h = thick / 2 - stubGap);
    }
  }
}

module connectorBar1() {
  dualStub(thick);
  translate([0, -2.5*thick, 0])
  for (i = [0, 1])
  mirror([i, 0, 0])
  slantedBend(angle = 90, rr=thick/2);
  translate([-thick/2, -barL-thick*2, 0])
  cube([thick, barL, thick]);
  translate([0, -barL-thick*3, 0])
  singleStub(thick*2);
}

module connectorBar2() {
  dualStub(2*thick);
  
  translate([0, -2.5*thick, 0])
  for (i = [0, 1])
  mirror([i, 0, 0])
  slantedBend(angle = 90, rr=thick/2);
  
  translate([-thick/2, -barL-thick*3/2, 0])
  cube([thick, barL, thick]);
  
  translate([0, -0.5*thick-barL, 0])
  mirror([0, 1, 0])
  for (i = [0, 1])
  mirror([i, 0, 0])
  slantedBend(angle = 90, rr=thick/2);
  
  translate([0, -barL-thick*3, 0])
  mirror([0, 1, 0])
  dualStub(thick);
}

module singleStubsInRing() {
  for (angle = [30: 120 : 359])
  rotate([0, 0, angle])
  for (i = [0, 1])
  mirror([0, i , 0])
  translate([0, sideL - thick * 1.3, 0])
  singleStub();
}

module evenRing() {
  ring();
  
  rotate([0, 0, 90])
  centerCube([sideL * sqrt(3), thick,  thick]);
  
  singleStubsInRing();
}

module centerCube(dim) {
  translate(-(dim - [0, 0, dim[2]])/2)
  cube(dim);
}

module rotateAt(rotation, center) {
  translate(center)
  rotate(rotation)
  translate(-center)
  children();
}

module connectorBar() {
connectorBar1();
translate([0, -barL - thick*3, 0])
connectorBar2();
}

module topStubs() {
  for (angle = [90: 120 : 359])
  rotate([0, 0, angle])
  translate([0, sideL - thick * 1.3, 0])
  singleStub();
}

module renderCage() {
  for (i = [0 : 3]) {
    z = i * 2 * (barL + thick*3);
    translate([0, 0, z])
    rotate([0, 0, i * 60])
    evenRing();
    
    for (j =   [0 : 3])
    translate([0, 0, z])
    rotate([0, 0, j * 120 + 30 + ((i % 2 == 0) ? 0 : 60)])
    translate([0, sideL - thick * 1.3, 0])
    rotateAt([-90,0,0], [0,0,thick/2])
    connectorBar();
  }
}

module renderCageFolded() {
  for (i = [0 : 3]) {
    z = i * thick;
    translate([0, 0, z])
    rotate([0, 0, i * 60])
    evenRing();
    
    for (j =   [0 : 3])
    translate([0, 0, z])
    rotate([0, 0, j * 120 + 30 + ((i % 2 == 0) ? 0 : 60)]) {
      translate([0, sideL - thick * 1.3, 0])
      connectorBar1();
      translate([0, sideL - thick * 1.3, 0])
      translate([0, -barL - thick*3, 0])
      rotateAt([180,0,0], [0, 0,thick])
      connectorBar2();
    }
  }
}

//renderCageFolded();
//translate([0, 0, cageTopHFolded()])
//topStubs();

function cageTopH() = 4 * 2 * (barL + thick*3);
function cageTopHFolded() = 4 * thick;
function stubH() = thick;
function stubL() = thick;

module connectorCubes() {
  gap = 0.3;
  for (angle = [0 : 120 : 359])
  rotate([0, 0, angle])
  translate([-thick*1.5, sideL - thick * 1.3 - barL - thick*4, 0]-gap*[1,1,0.01])
  cube([thick*3, barL + thick*4.5, thick] + gap*2*[1,1,1]);
}



//connectorCubes();


//translate(22*[1,0.2,1])
//sphere(r=25/2, $fn = 7);

//evenRing();
//connectorBar();

borderHingeL = sideL - 2.51*thick;
borderHingeP = [-borderHingeL/2, sideL - thick + 5.1*e, 0];
module diceRamp() {
  applyHinges(
    [
      [-sideL/2, -sideL + 2*thick, 0],
      [sideL/2, -sideL + 2*thick, 0]
    ], // Positions
    [90, 90], // Rotations
    thick/2, // Radius
    thick/2, // Corner height
    sideL*2 - thick * 4, // Lenght
    10, // Pieces
    5*e) // Offset
  difference() {
    hull()
    ring();

    for (i = [0, 1]) mirror([i, 0, 0])
    translate([-sideL/2 - 5*e/2, -sideL*1.5, -e])
    cube([5*e, sideL*3, thick + 2*e]);


    for (i = [0, 1]) mirror([i, 0, 0])
    for (j = [0, 1]) mirror([0, j, 0])
    translate([sideL/2 + 2.5*e, sideL - thick + 4*e, -e])  
    cylinder(r = thick + 2*5*e, h = thick + 2*e, $fn=6);

    translate(borderHingeP)
    hingeCorner(thick/2, thick/2, borderHingeL, 6, false, true, 5*e);
  }
  translate(borderHingeP)
  hingeCorner(thick/2, thick/2, borderHingeL, 6, false, false, 5*e);
}

module diceRampHinge(isNegative) {
  translate(borderHingeP + [0, 0, -thick/2])
  hingeCorner(thick/2, thick, borderHingeL, 6, true, isNegative, 5*e);
}

module diceRampMock(angle = 0) {
  for(i = [0, 1]) mirror([i, 0, 0])
  rotateAt([0, angle, 0], [-sideL/2, 0, thick/2])
  difference() {
    hull()
    ring();  
    
    translate([-sideL/2 - thick/2, -50, -e])
    cube([100,100,10]);
  }

  translate([-sideL/2 + 0.5*thick, -sideL + thick, -e])
  cube([sideL - 1*thick, 2*sideL - 2*thick, thick]);
}

module diceTray(h = 25) {
  ring(h);
  hull() ring();
}