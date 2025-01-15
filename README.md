# PhaseMetrics-macros
FIJI/ImageJ macros for running PhaseMetrics (versions for in vitro and cellular datasets). For more information please refer to the corresponding publication:  https://www.jbc.org/article/S0021-9258(24)02632-2/fulltext. 

PhaseMetrics instruction manual
Initiation:
1.	Upon opening Fiji install required update sites for proper functioning of macro:
	Help > Update… > Manage Update Sites > Select Excel Functions, and if not already selected Bio-Formats > Apply and Close > Apply Changes > Re-start Fiji.
2.	To standardize settings for opening images, upon re-start go to:
	Plugins > Bio-Formats > Bio-Formats Windowless Importer > Choose desired image. From now on all images, will be opened with the same settings as used for the selected image.
*Step 1 and 2 only have to be performed once upon first time use.

Defining settings:

3.	Open select number of images that properly reflect the total variability of structures seen between different conditions to be analysed.
4.	For multi-channel images, split channels:
	Image > Color > Split Channels.
5.	For each of the channels to analyse, determine radius for rolling ball background subtraction method. This should be set to at least the size of the largest object not being part of the background. 
*Standardly set to 50.
6.	Once the size of the largest object has been determined, subtract background:
	Process > Subtract Background... > Set radius > Ok.
7.	Generate a Z-projection for generating the thresholded mask for image segmentation:
	Image > Stacks > Z Project... > Select desired projection type. 
*Typically, the "Max Intensity" projection works well for segmentation of bright foci and the "Sum Slices" for segmentation of diffuse signals (e.g. generation of CellMasks).
8.	(Optional) Select Filters for noise reduction and/or signal enhancement:
	Process > Filters > Selection of desired filters. 
*Different Filter options can be evaluated using Preview box. Multiple filters can be successively applied. Figure S2 illustrates an example of the use of filtering options for improved segmentation.
9.	Convert Filtered image to binary image, and generate threshold montage:
	Image > Type > 8-bit > Adjust > Auto Threshold > Method: Try all*
*Resulting threshold montage gives an overview of all available thresholding algorithms within FIJI for selection of threshold that fits best. The name of the corresponding thresholding methods are indicated at the bottom centre of each of the masked panels (Zoom-in to visualize names).

Initiation PhaseMetrics:

10.	To run PhaseMetrics using the simple graphical user interface, either:
	Copy-paste the desired script(s) (PhaseMetrics_invitro.ijm or PhaseMetrics_cellular.ijm) into the macros folder of FIJI > go to FIJI > Plugins > Install… > Select PhaseMetrics script > Save in plugins folder of FIJI > Re-start FIJI. From now on, the PhaseMetrics script can standardly be accessed from: FIJI > Plugins > scroll down to bottom of list.
11.	To run PhaseMetrics using the command-line interface:
	Drag the desired script into FIJI.
12.	Once finished, the selected parameters can be filled in the dialog box that appears upon initiation of the plugin: 
*	When only one channel is to be analysed, the parameter requests for the other channel(s) can be ignored during setup. 
*	Selected filters can be activated by selecting the corresponding checkboxes for the appropriate channel(s). 
*	Filter settings (Radius, Maskweight) only have to be specified for the selected filters (per channel). Selected settings will be remembered for future use, and have to be reset if different settings are desired.
13.	After selection of desired settings, multiple dialog boxes will appear consecutively for activation of the desired analysis modules. 
*	For the PhaseMetrics_invitro variant, the user will be requested to specify whether a measurement of the soluble fraction is desired, and whether a single or multichannel image is to be analysed. If the multichannel module is activated, the user will subsequently be asked whether an analysis of objects in the second channel (phase modulator) is desired, as well as the option to perform an object-based colocalization test to define the intersected and no-coloc regions between the objects detected in both channels. 
*	For the PhaseMetrics_cellular variant, the user will be requested to specify whether a single or multichannel image is to be analysed. When the multichannel module is activated, the standard assumption is that a particle and cell channel are to be analysed. The user will additionally be asked whether an analysis of an additional channel is desired, corresponding to PhaseModulator particles.
*	Next, the user will consecutively be requested to specify whether analysis of the cells channel, an object-based particle/cell analysis, measurement of the soluble fraction, and object-based colocalization test to define the intersect between the particles and PhaseModulator particles, is desired.
