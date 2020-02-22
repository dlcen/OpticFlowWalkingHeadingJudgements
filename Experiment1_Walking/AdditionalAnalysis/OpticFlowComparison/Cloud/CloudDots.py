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

Target = vizshape.addCylinder(height = 3, radius = 0.02)  # Create a post to be the target. 
Target.setPosition([0, 1.5, 7], viz.ABS_GLOBAL)           # Place the target at 7m from the starting point

vol_height = 3 			# Height of the volume
vol_width  = 12 		# Width of the volume
vol_depth  = 12 		# Depth of the volume

Target_offset = 1 		# Distance between the target and the boundary of the cloud behind

n_dots = 6300 			# Number of dots to be included in the cloud

flashingCloud(3, 12, 12, 1, 6300, Target) 	# Create a cloud and save the location of each dot in the 3D space
