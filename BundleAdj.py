# Performing Bundle Adjustment
from scipy.io import loadmat
from PySBA import PySBA
import numpy as np
import cv2
import matplotlib.pyplot as plt
from scipy.sparse import lil_matrix


"""Loading in the .mat file from the BundleAdjustmentData.m code
"""
mat = loadmat(r"C:\Users\12053\Documents\Dunn_Research\BundleAdjustment.mat")


"""Creating variables for each variable from MATLAB code
"""
points_2D = mat['points_2D']
points_3D = mat['new_data3D']
cam_ind = mat['cam_ind']
point_ind = mat['point_ind']
cam_array = mat['camera_Array']
prin_off = mat['prin_off']


"""Reshaping the camera indices and point indices vectors
"""
cam_ind1 = cam_ind.reshape(np.shape(cam_ind)[0],)
point_ind1 = point_ind.reshape(np.shape(point_ind)[0],)


"""Calling the PySBA class from another code
Getting the new camera parameters using the bundleAdjust function
The commented out line can be used to save the new parameters to a txt file
"""
my_bundle = PySBA(cam_array,points_3D,points_2D,cam_ind1,point_ind1,prin_off)
new_params = my_bundle.bundleAdjust()
# np.savetxt('newparams_20220527_w6_c1_m1_cut.txt',new_params[0], delimiter=',')


"""Testing the error of the old parameters
"""
x0 = np.hstack((my_bundle.cameraArray.ravel(), my_bundle.points3D.ravel()))
camera_params = x0[:54].reshape((6,9))
cam = camera_params[cam_ind1]
# np.savetxt('err_orig.txt',f0, delimiter=',', fmt = '%1.3f')

points_proj = my_bundle.project(points_3D[point_ind1], cam, prin_off[cam_ind1])
euclid = np.linalg.norm((points_proj-points_2D), axis=1)[:, np.newaxis]
# np.savetxt('errors_4.txt',euclid, delimiter=',', fmt = '%1.3f')


"""Plotting a histogram of the errors
"""
plt.figure(1)
plt.hist(euclid)
plt.xlabel('Errors')
plt.title('05.27 Errors (small cylinder)')
plt.xlim([0,13])
plt.show()
