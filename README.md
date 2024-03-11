<img alt="Static Badge" src="https://img.shields.io/badge/Window%20Smoothing%20Model-blue"> <img alt="Static Badge" src="https://img.shields.io/badge/Optimal%20Fringe%20Number%20Calibration-red"> <img alt="Static Badge" src="https://img.shields.io/badge/MEMS%20FPP-green">

# IMPORTANT
The folder of "Code" provides the codes of model calibration and optimal fringe number calibration.

The folder of "Data" provides a set of phase-shifted patterns, where a whiteboard at a certain working distance are projected.

Please place the two folders (i.e., "Code" and "Data") in same root to properly read the pattern.


# Help Documentation of File "Window_Smoothing_Theory.m"
This file can calibrate the window-smoothing model and the optimal fringe number for a given MEMS-based FPP system.

The calibration is performed in the manner of pixel-wise.

## Data Preparation
Capture the multi-frequency phase-shifting patterns at the different working distances in the measurement space of FPP.

Place captured patterns in the "Data\Pattern\" folder. 

The naming format of the pattern should be "distance_frequency_shift.bmp". 

For example, "1_2_3.bmp" means the third phase-shifting images of the second phase frequency of the first distance.

## Algorithm Process
1) Initialization
   
		→ According the Gaussian intensity distribution within linewidth, the model parameters a1-a4 are initialized.
2) Calculate Decay Factor λ
   
		→ Calculate background intensity Ac. 
		→ Calculate Modulation intensity Bc. 
3) Model Fitting
   
		→ The model parameters  a1-a4  are calibrated in manner of pixel-wise. 
		→ To speed up the fitting, a interpolation method is used.
4) Optimal Fringe Number Search
   
		→ Acoording to the model parameters, search the optimal fringe number in manner of pixel-wise.
5) Show Model Paramerters a1-a4 (Pixel-wise)
    
		→ Show the distribution of model parameters a1-a4 of pixels in a 2D image 
		→ Show the mean fitting residuals
6) Show Optimal Fringe Number (Pixel-wise)
   
		→ Show the distribution of optimal fringe numbe of pixels in a 2D image 


# Help documentation of file "Phase_Retrieval.m"
Phase_Retrieval.m cam be used to calculate absolute phase, background intensity, and modulation intensity with multi-frequency phase-shifting Patterns.

<img alt="Static Badge" src="https://img.shields.io/badge/Han%20Min-%40Tsinghua-purple"> <img alt="Static Badge" src="https://img.shields.io/badge/Email%3A-hanm21%40mails.tsinghua.edu.cn-yellow">




