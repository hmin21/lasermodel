# IMPORTANT
The folder of "Code" provides samples of laser linewidth model calibration and optimal fringe number calibration algorithms.
The folder of "Data" provides several sets of images of phase-shifted fringe at different distances on a flat board.
Please place the two folders (i.e., "Code" and "Data") in same root to order not to change the file path in the codes.

# Help documentation of file "Exp1_Laser_Model_Calibration.m"
Exp1_Laser_Model_Calibration.m can be used to perform pixel-by-pixel system calibration of MEMS line laser systems.
## Data preparation
Capture the phase shift images at the desired working distance and place it in the "Data" folder. 
The naming format should be "group_frequency_shift.bmp", and "1_2_3.bmp" means the third phase shift images of the second frequency of the first group.
## Laser model calibration process
The 1st section calibrates the model parameters a1-a4 in manner of pixel-wise. To speed up the fitting, a interpolation method is used.
The 2nd section shows the distribution of model parameters a1-a4 of pixels in a 2D image and thier fitted residuals.

# Help documentation of file "Exp2_Optimal_Algorithm_Calibration.m"
Exp2_Optimal_Algorithm_Calibration.m estimates the optimal fringe number for a given MEMS-based system.
## Data preparation
Capture the phase shift images at several working distances and place it in the "Data" folder.Data for each distance is placed in a separate folder 
The naming format should be "group_frequency_shift.bmp", and "1_2_3.bmp" means the third phase shift images of the second frequency of the first group.
## Optimal algorithm calibration process
The 1st section performs phase resolution of the initial images acquired and fits parameters in the window smoothing model.
The 2nd section shows the optimal frequency number 2D distribution.
The 3rd section shows the optimal fringe number at a particular pixel.

# Help documentation of file "Phase_Retrieval.m"
Phase_Retrieval.m cam be used to calculate absolute phase, background intensity, and modulation intensity with phase-shift images.

