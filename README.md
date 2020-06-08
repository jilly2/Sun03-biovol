# Sun03-biovol
Jill Schwarz 20200608: Interactive measurement of phytoplankton dimensions and calculation of biovolume, after 
Sun, J., D. Liu, 2003. Geometric models for calculating cell biovolume and surface area for phytoplankton. J. Plankton Res. 25(11), 1331-1346.

This code was written for, and only tested on, MacOS 10.12.6.

Code files:  biovolSun03.m, processPhotos_example.m

Input data files: ChagosMicroscopy_counts_example.xlsx, photos in directory XXV_2_20200408.

Output data file: processPhotos_example.m writes a dynamically-named .mat file.

Description:

The core function, biovolSun03.m, allows you to take measurements interactively from a figure window in which a photograph of the cell is shown.

Edit the biovolSun03.m script to add your own calibration - how many millimetres does one of your camera pixels represent? Here, the full FOV width and the camera FOV width were measured using a 20 lines/mm interference grating. Five grating lines were counted across the camera field of view (5/20 = 0.25 mm). The camera images are 5184 pixels across, yielding 0.25 mm / 5184 pixels as the resolution (code line 32).
 
No check is made within biovolSun03.m for multiple figure windows - the active figure will be used. ctrl+C to break manually in case of error.

The code that calls biovolSun03.m for my dataset is processPhotos_example.m. This code uses an Excel spreadsheet in which microscopy data were recorded to pull up successive phytoplankton (and protozoa/other interesting features) one by one, to be measured using biovolSun03.m.  This is very specific to my way of storing the data from these samples.

File ChagosMicroscopy_counts_example.xlsx illustrates the microscopy log and is one input to the processPhotos_example.m.  When I run this code, I make a note of the shape used to calculate biovolume for each cell in a separate copy of the input Excel file. Cell sizing information is stored in .mat files, in the variable struct st. I merge this information with my cell count data separately.

Directory XXV_2_20200408 contains the first 20 photos as an example of the second input to processPhotos.m. 

The file input and output paths are specified at the beginning of processPhotos.m and would need to be adapted to your system if you wish to use this code!

This code is offered with no warranty for correctness and no liability for errors or technical problems. You are free to edit, adapt and redistribute the code.
