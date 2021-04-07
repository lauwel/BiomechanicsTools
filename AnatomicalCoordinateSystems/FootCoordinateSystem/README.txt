FOOT COORDINATE SYSTEM DOCUMENTATION
OVERVIEW
The code ‘generateFootCoordinateSystems.m’ will take the .iv files of the bones you select and generate aligned co-ordinate systems with the lab convention. 
The foot coordinate systems are oriented such that lateral (right foot) is X, anterior is Y and superior is Z. 
DETAILS
Currently, it handles the all bones except for toes (other than ph1). 
To add bones, use the generateTemplateFootCoordinateSystems.m, manually rotating the inertial co-ordinate systems of each bone to be aligned with the lab convention. 
The inertial axes (from mass_properties.m) have been calculated and oriented for a reference foot.
Using an initial orientation check and Coherent Point Drift (rigid), the bones are roughly aligned with the reference bone. 
The inertial axes of the bone are then aligned using a custom code that matches the x axes and then rotates the coordinate system until the other axes match as well.

Shape based co-ordinate systems are created based on joint surfaces. 
Currently, there are two shape-based co-ordinate systems for the tibia and two for the talus. 
The tibia has one that aligns primarily with the long axis of the tibia (based on a cylindrical fit of the shaft of the tibia).
The talus and tibia both have a talocrural axis (TC) that is based on a cylinder fit with the dome (tib/tal dome). 
Note that the origin of the co-ordinate system is always at the centroid.
The talus also has a subtalar axis (ST) as defined by Montefiori 2019 (https://doi.org/10.1016/j.jbiomech.2018.12.041).
	
