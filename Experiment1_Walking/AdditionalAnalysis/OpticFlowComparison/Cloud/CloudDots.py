import viz vizshape vizmat
import numpy as np

def flashingCloud(height, width, depth, offset, number, node):

	positions = np.random.uniform(low = -width/2, high = width/2, size = (number, 3))
	positions[:, 1] = positions[:, 1]/(width/height) 

	# Save the location of each dots into a .csv file
	record = open('Cloud_positions_' + str(number) + '.csv', 'a' ) 	

	for n in range(number):
		record.write(str(positions[n, 0]) + ',' + str(positions[n, 1]) + ',' + str(positions[n, 2]) + '\n')

	positions[:, 2] = positions[:, 2] - (depth/2 - offset) 

	clouds = []
	
	viz.startLayer(viz.POINTS)
	viz.pointSize(2)  # Set the size of the dots on the display

	# Draw each dot
	for i in range(number):
		viz.vertex(positions[i, 0], positions[i, 1], positions[i, 2])

	cloud = viz.endLayer()

	# Set a parent object for the cloud.
	# Therefore, once the location of the parent is determined, the location of the cloud as a whole is also determined.
	cloud.setParent(node) 

	return cloud


viz.go()

# Create a post to be the target. 
Target_height = 3
Target_radius = 0.02
Target_distance = 7 	# Place the target at 7m from the starting point

Target = vizshape.addCylinder(height = Target_height, radius = Target_radius)  
Target.setPosition([0, Target_height/2, Target_distance], viz.ABS_GLOBAL)           

vol_height = 3 			# Height of the volume
vol_width  = 12 		# Width of the volume
vol_depth  = 12 		# Depth of the volume

Target_offset = Target_distance - vol_depth/2;	

n_dots = 6300 			# Number of dots to be included in the cloud

flashingCloud(vol_height, vol_width, vol_depth, Target_offset, n_dots, Target) 	# Create a cloud and save the location of each dot in the 3D space
