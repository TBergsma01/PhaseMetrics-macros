//------------------------------------------------------------------------
//[PhaseMetrics] image analysis pipeline for quantitative assessment of biomolecular condensate properties - cellular experiments
//------------------------------------------------------------------------
/*
 *Author : Tessa Bergsma
 *European Research Institute for the Biology of Ageing, University of Groningen
/*Date: May 29, 2023
 *
 *Preprocesses z-stacks, creates Z-projection images, and analyzes particle properties (e.g. size, shape descriptors such as circularity, and intensity measurements).
 *The multi-channel module analyzes objects in all channels and has the additive functionality to run object-based colocalization tests (Particle/cell analysis, soluble fraction measurement, determining regions of intersection between particles and phase modulating protein particles). 
 */

//Initialization
//To allow for use of extension commands
run("Excel Macro Extensions", "debuglogging=false"); 
run("Options...", "iterations=1 count=1 black edm=Overwrite");
run("Colors...", "foreground=white background=black selection=yellow");
//To clean workspace
run("Clear Results");
close("Log");
run("Close All");

////// Parameters (Ctrl+/ to comment or uncomment)
#@ File(label="Input data:", value = "E:/", style= "directory") input
#@ String Imagetype
#@ String (visibility=MESSAGE, value="<html><li>Channel selection_______________________________________________________________________________________________", required=false) msg
#@ String(label="Particle channel", choices={"C1-","C2-","C3-"}, style = "listBox") Particle_C
#@ String(label="Cell channel", choices={"C1-","C2-","C3-"}, style = "listBox") Cell_C
#@ String(label="PhaseModulator channel", choices={"C1-","C2-","C3-"}, style = "listBox") PM_C
#@ String (visibility=MESSAGE, value="<html><li>Assigning lookup tables (coloring) to channels__________________________________________________________________", required=false) msg1
#@ String(label="ColorLUT_Particle", choices={"Fire","Grays","Ice","Spectrum","3-3-2 RGB","Red","Green","Blue","Cyan","Magenta","Yellow","Red/Green"}, style = "listBox") LUT_Particle
#@ String(label="ColorLUT_Cell", choices={"Fire","Grays","Ice","Spectrum","3-3-2 RGB","Red","Green","Blue","Cyan","Magenta","Yellow","Red/Green"}, style = "listBox") LUT_Cell
#@ String(label="ColorLUT_PhaseModulator", choices={"Fire","Grays","Ice","Spectrum","3-3-2 RGB","Red","Green","Blue","Cyan","Magenta","Yellow","Red/Green"}, style = "listBox") LUT_PM
#@ String (visibility=MESSAGE, value="<html><li>Assigning “rolling ball” radius for background subtraction _____________________________________________________", required=false) msg2
#@ Integer(label="Background substraction_Particle", value = 50, style = "spinner") BGSub_Particle
#@ Integer(label="Background substraction_Cell", value = 50, style = "spinner") BGSub_Cell
#@ Integer(label="Background substraction_PhaseModulator", value = 50, style = "spinner") BGSub_PM
#@ String (visibility=MESSAGE, value="<html><li>Assigning Image crop dimensions ________________________________________________________________________________", required=false) msg3
#@ Integer(label="Crop_x", value = 0, style = "spinner") Crop_x 
#@ Integer(label="Crop_y", value = 0, style = "spinner") Crop_y 
#@ Integer(label="Crop_width", value = 0, style = "spinner") Crop_width 
#@ Integer(label="Crop_height", value = 0, style = "spinner") Crop_height 
#@ String (visibility=MESSAGE, value="<html><li>Filtering for particle channel___________________________________________________________________________________", required=false) msg4
#@ boolean(label="Gaussian blur_Particle") Gaussian_Particle
#@ Float(label="Gaussian sigma_Particle", style = "spinner", stepSize=0.01, value = 0) Gaussian_sigma_Particle
#@ boolean(label="Median_Particle") Median_Particle
#@ Float(label="Median Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Median_radius_Particle
#@ boolean(label="Mean_Particle") Mean_Particle
#@ Float(label="Mean Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Mean_radius_Particle
#@ boolean(label="Minimum_Particle") Minimum_Particle
#@ Float(label="Minimum Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Minimum_radius_Particle
#@ boolean(label="Maximum_Particle") Maximum_Particle
#@ Float(label="Maximum Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Maximum_radius_Particle
#@ boolean(label="Unsharp mask_Particle") UnsharpMask_Particle
#@ Float(label="Unsharp mask Radius_Particle", style = "spinner", stepSize=0.01, value = 0) UnsharpMask_radius_Particle
#@ Float(label="Unsharp mask MaskWeight_Particle", style = "spinner", stepSize=0.1, value = 0) UnsharpMask_maskweight_Particle
#@ boolean(label="Tophat_Particle") Tophat_Particle
#@ Float(label="Tophat radius_Particle", style = "spinner", stepSize=0.01, value = 0) Tophat_radius_Particle
#@ String (visibility=MESSAGE, value="<html><li>Filtering for cell channel______________________________________________________________________________________", required=false) msg5
#@ boolean(label="Gaussian blur_Cell") Gaussian_Cell
#@ Float(label="Gaussian sigma_Cell", style = "spinner", stepSize=0.01, value = 0) Gaussian_sigma_Cell
#@ boolean(label="Median_Cell") Median_Cell
#@ Float(label="Median Radius_Cell", style = "spinner", stepSize=0.01, value = 0) Median_radius_Cell
#@ boolean(label="Mean_Cell") Mean_Cell
#@ Float(label="Mean Radius_Cell", style = "spinner", stepSize=0.01, value = 0) Mean_radius_Cell
#@ boolean(label="Minimum_Cell") Minimum_Cell
#@ Float(label="Minimum Radius_Cell", style = "spinner", stepSize=0.01, value = 0) Minimum_radius_Cell
#@ boolean(label="Maximum_Cell") Maximum_Cell
#@ Float(label="Maximum Radius_Cell", style = "spinner", stepSize=0.01, value = 0) Maximum_radius_Cell
#@ boolean(label="Unsharp mask_Cell") UnsharpMask_Cell
#@ Float(label="Unsharp mask Radius_Cell", style = "spinner", stepSize=0.01, value = 0) UnsharpMask_radius_Cell
#@ Float(label="Unsharp mask MaskWeight_Cell", style = "spinner", stepSize=0.1, value = 0) UnsharpMask_maskweight_Cell
#@ boolean(label="Tophat_Cell") Tophat_Cell
#@ Float(label="Tophat_radius_Cell", style = "spinner", stepSize=0.01, value = 0) Tophat_radius_Cell
#@ String (visibility=MESSAGE, value="<html><li>Filtering for phasemodulator channel______________________________________________________________________________", required=false) msg6
#@ boolean(label="Gaussian blur_PhaseModulator") Gaussian_PM
#@ Float(label="Gaussian sigma_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Gaussian_sigma_PM
#@ boolean(label="Median_PhaseModulator") Median_PM
#@ Float(label="Median Radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Median_radius_PM
#@ boolean(label="Mean_PhaseModulator") Mean_PM
#@ Float(label="Mean Radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Mean_radius_PM
#@ boolean(label="Minimum_PhaseModulator") Minimum_PM
#@ Float(label="Minimum Radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Minimum_radius_PM
#@ boolean(label="Maximum_PhaseModulator") Maximum_PM
#@ Float(label="Maximum Radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Maximum_radius_PM
#@ boolean(label="Unsharp mask_PhaseModulator") UnsharpMask_PM
#@ Float(label="Unsharp mask Radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) UnsharpMask_radius_PM
#@ Float(label="Unsharp mask MaskWeight_PhaseModulator", style = "spinner", stepSize=0.1, value = 0) UnsharpMask_maskweight_PM
#@ boolean(label="Tophat_PhaseModulator") Tophat_PM
#@ Float(label="Tophat_radius_PhaseModulator", style = "spinner", stepSize=0.01, value = 0) Tophat_radius_PM
#@ String (visibility=MESSAGE, value="<html><li>Threshold selection___________________________________________________________________________________________", required=false) msg7
#@ String(label="Thresholding method_Particle", choices={"Otsu","RenyiEntropy","Yen","Moments","Minimum","Maximum","Huang","Huang2","Li","MaxEntropy","Percentile","Shanbhag","Triangle","Intermodes","IsoData","Mean","MinError(I)"}, style = "listBox") Threshold_Particle
#@ String(label="Thresholding method_Cell", choices={"Otsu","RenyiEntropy","Yen","Moments","Minimum","Maximum","Huang","Huang2","Li","MaxEntropy","Percentile","Shanbhag","Triangle","Intermodes","IsoData","Mean","MinError(I)"}, style = "listBox") Threshold_Cell
#@ String(label="Thresholding method_PhaseModulator", choices={"Otsu","RenyiEntropy","Yen","Moments","Minimum","Maximum","Huang","Huang2","Li","MaxEntropy","Percentile","Shanbhag","Triangle","Intermodes","IsoData","Mean","MinError(I)"}, style = "listBox") Threshold_PM
#@ String (visibility=MESSAGE, value="<html><li>Size cutoffs__________________________________________________________________________________________________", required=false) msg8
#@ Float(label="Area min cutoff_Particle", style="spinner", stepSize=0.01, value=0) area_L_cutoff_Particle
#@ Float(label="Area max cutoff_Particle", style="spinner", stepSize=0.01, value=1000) area_M_cutoff_Particle
#@ Float(label="Area min cutoff_Cell", style="spinner", stepSize=0.01, value=0) area_L_cutoff_Cell
#@ Float(label="Area max cutoff_Cell", style="spinner", stepSize=0.01, value=0) area_M_cutoff_Cell
#@ Float(label="Area min cutoff_PhaseModulator", style="spinner", stepSize=0.01, value=0.02) area_L_cutoff_PM
#@ Float(label="Area max cutoff_PhaseModulator", style="spinner", stepSize=0.01, value=10) area_M_cutoff_PM

Channels = getBoolean("Multichannel?");
C3 = getBoolean("Analysis of third channel (PhaseModulator particles)?");

if (Channels == 0) {
//------------------------------------------------------------------------
// Single-channel module
//------------------------------------------------------------------------
//Create output folders images
File.makeDirectory(input + "/Output");
output = input + "/Output/";
File.makeDirectory(input + "/Output/Montage");
output_threshold_montage = output + "Montage/";
File.makeDirectory(input + "/Output/Max");
output_max = output + "Max/";
File.makeDirectory(input + "/Output/Sum");
output_sum = output + "Sum/";

//Create output folders results
File.makeDirectory(input + "/Output/Results");
output_results = output + "Results/";
File.makeDirectory(input + "/Output/ROIs");
output_rois = output + "ROIs/";

//Save settings
settings ("Log");
saveAs("Text", output+"Settings.txt");
close("Log");

//get list of files from input folder
input = input + "/";
files = getFileList(input);
files = ImageFilesOnlyArray(files);

//activate batch mode
setBatchMode(true);

//Particle analysis
// LOOP to process the list of files
for (i=0; i<files.length; i++) {
 print("\\Update0: Particle_processing image: " + i+1 + " of " + files.length);
 //concatenate dir and the i element of the array fileList and open images
 open(input+files[i]);
 Filename = clean_title(files[i]);
 rename(Filename);

 //start macro
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 //run("Duplicate...", "duplicate frames=1");
 Filename = getTitle();

 run(LUT_Particle);
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Subtract Background...", "rolling="+BGSub_Particle+" stack");
 run("Z Project...", "projection=[Sum Slices]");
 run(LUT_Particle);
 Sum = getTitle();
 run("Duplicate...", " ");
 Sum_1 = getTitle();
 selectWindow(Sum_1);
 saveAs("Tiff", output_sum+files[i]);

 selectWindow(Filename);
 run("Z Project...", "projection=[Max Intensity]");
 Max = getTitle();
 run("Duplicate...", " ");
 saveAs("Tiff", output_max+files[i]);
 selectWindow(Max);
 run("Duplicate...", " ");
 //Apply filters
 if (Gaussian_Particle == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_Particle+"");
 }
 if (Median_Particle == 1 ) {
 	 run("Median...", "radius="+Median_radius_Particle+"");
 }
 if (Mean_Particle == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_Particle+"");
 }
 if (Minimum_Particle == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_Particle+"");
 }
 if (Maximum_Particle == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_Particle+"");
 }
 if (UnsharpMask_Particle == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_Particle+" mask="+UnsharpMask_maskweight_Particle+"");
 }
 if (Tophat_Particle == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_Particle+"");
 }
 Max_1 = getTitle();
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method=[Try all] white"); //Auto threshold runs through all available thresholding algorithms within FIJI and creates an overview for selection of threshold that best fits dataset.
 saveAs("Tiff", output_threshold_montage+files[i]);

 selectWindow(Max_1);
 run("Auto Threshold", "method="+Threshold_Particle+" white");
 run("Convert to Mask");
 if (Maximum_Particle == 1 ) {
 	  run("Erode");
 }
 //Set relevant measurements to be extracted from detected objects
 run("Set Measurements...", "area mean min centroid perimeter bounding shape feret's integrated skewness kurtosis limit display redirect=["+ Sum +"] decimal=3");
 run("Analyze Particles...", "size="+area_L_cutoff_Particle+"-"+area_M_cutoff_Particle+" exclude add");

 //Save ROIs 
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[i]+'-ROIset_Particle.zip');
 ROI_measure("ROI Manager");  //Function to include ROI coordinates in measurements sheet for coloc test
}
}
clean_results("Results"); //Remove redundant columns
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Particle", true);
close("*");
close("Log");
close("Results");
close("Summary");
print("Analysis finished.");
}
else if (Channels == 1) {
//------------------------------------------------------------------------
// Multi-channel module
//------------------------------------------------------------------------
File.makeDirectory(input + "/Output");
output = input + "/Output/";
File.makeDirectory(input + "/Output/Montage");
output_threshold_montage = output + "Montage/";
File.makeDirectory(input + "/Output/Montage/Particle");
output_montage_Particle = output_threshold_montage + "Particle/";
File.makeDirectory(input + "/Output/Montage/Cells");
output_montage_Cells = output_threshold_montage + "Cells/";
File.makeDirectory(input + "/Output/Max");
output_max = output + "Max/";
File.makeDirectory(input + "/Output/Max/Particle");
output_max_Particle = output_max + "Particle/";
File.makeDirectory(input + "/Output/Max/Cells");
output_max_Cells = output_max + "Cells/";
File.makeDirectory(input + "/Output/Max/Merged");
output_max_merged = output_max + "Merged/";
File.makeDirectory(input + "/Output/Sum");
output_sum = output + "Sum/";
File.makeDirectory(input + "/Output/Sum/Particle");
output_sum_Particle = output_sum + "Particle/";
File.makeDirectory(input + "/Output/Sum/Cells");
output_sum_Cells = output_sum + "Cells/";
File.makeDirectory(input + "/Output/Sum/Merged");
output_sum_merged = output_sum + "Merged/";

if(C3 == 1){
File.makeDirectory(input + "/Output/Montage/PhaseModulator");
output_montage_PhaseModulator = output_threshold_montage + "PhaseModulator/";
File.makeDirectory(input + "/Output/Max/PhaseModulator");
output_max_PhaseModulator = output_max + "PhaseModulator/";
File.makeDirectory(input + "/Output/Sum/PhaseModulator");
output_sum_PhaseModulator = output_sum + "PhaseModulator/";
}

File.makeDirectory(input + "/Output/Results");
output_results = output + "Results/";
File.makeDirectory(input + "/Output/ROIs");
output_rois = output + "ROIs/";

settings ("Log");
saveAs("Text", output+"Settings.txt");
close("Log");

input = input + "/";
files = getFileList(input);
files = ImageFilesOnlyArray(files);

setBatchMode(true);
//Particle channel analysis 
for (i=0; i<files.length; i++) {
 print("\\Update0:Particles_processing image: " + i+1 + " of " + files.length);

 open(input+files[i]);
 Filename = clean_title(files[i]); //Functions listed at bottom of script
 rename(Filename);

 //start macro
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 Sum_Particle = "SUM_" + Particle;
 Sum_Cells = "SUM_" + Cells_2;
 Max_Particle = "MAX_" + Particle;
 Max_Cells = "MAX_" + Cells_2;
 if(C3 == 1){
 PM = PM_C + Filename;
 Sum_PM = "SUM_" + PM;
 Max_PM = "MAX_" + PM;
 }

 //Creating and saving of max, and sum projections
 create_Zprojections(Filename);
 selectWindow(Sum_Particle);
 run("Duplicate...", " ");
 saveAs("Tiff", output_sum_Particle+files[i]);
 selectWindow(Max_Particle);
 run("Duplicate...", " ");
 saveAs("Tiff", output_max_Particle+files[i]);
 selectWindow(Sum_Cells);
 run("Duplicate...", " ");
 saveAs("Tiff", output_sum_Cells+files[i]);
 selectWindow(Max_Cells);
 run("Duplicate...", " ");
 saveAs("Tiff", output_max_Cells+files[i]);
 if(C3 == 1){
 selectWindow(Sum_PM);
 run("Duplicate...", " ");
 saveAs("Tiff", output_sum_PhaseModulator+files[i]);
 selectWindow(Max_PM);
 run("Duplicate...", " ");
 saveAs("Tiff", output_max_PhaseModulator+files[i]);
 }

 //Creating Thresholding methods montage
 selectWindow(Max_Particle);
 run("Duplicate...", " ");
 if (Gaussian_Particle == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_Particle+"");
 }
 if (Median_Particle == 1 ) {
 	 run("Median...", "radius="+Median_radius_Particle+"");
 }
 if (Mean_Particle == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_Particle+"");
 }
 if (Minimum_Particle == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_Particle+"");
 }
 if (Maximum_Particle == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_Particle+"");
 }
 if (UnsharpMask_Particle == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_Particle+" mask="+UnsharpMask_maskweight_Particle+"");
 }
 if (Tophat_Particle == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_Particle+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method=[Try all] white");
 saveAs("Tiff", output_montage_Particle+files[i]);

 selectWindow(Sum_Cells);
 run("Duplicate...", " ");
 if (Gaussian_Cell == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_Cell+"");
 }
 if (Median_Cell == 1 ) {
 	 run("Median...", "radius="+Median_radius_Cell+"");
 }
 if (Mean_Cell == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_Cell+"");
 }
 if (Minimum_Cell == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_Cell+"");
 }
 if (Maximum_Cell == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_Cell+"");
 }
 if (UnsharpMask_Cell == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_Cell+" mask="+UnsharpMask_maskweight_Cell+"");
 }
 if (Tophat_Cell == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_Cell+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method=[Try all] white");
 saveAs("Tiff", output_montage_Cells+files[i]);

 if (C3 ==1){
 selectWindow(Max_PM);
 run("Duplicate...", " ");
 if (Gaussian_PM == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_PM+"");
 }
 if (Median_PM == 1 ) {
 	 run("Median...", "radius="+Median_radius_PM+"");
 }
 if (Mean_PM == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_PM+"");
 }
 if (Minimum_PM == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_PM+"");
 }
 if (Maximum_PM == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_PM+"");
 }
 if (UnsharpMask_PM == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_PM+" mask="+UnsharpMask_maskweight_PM+"");
 }
 if (Tophat_PM == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_PM+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method=[Try all] white");
 saveAs("Tiff", output_montage_PhaseModulator+files[i]);
 }

 if (C3 == 0){
 //Create merged images using the maximum intensity and sum of slices projections
 run("Merge Channels...", "c1=" + Max_Cells + " c2=" + Max_Particle + " create keep");
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_max_merged+files[i]);
 run("Merge Channels...", "c1=" + Sum_Cells + " c2=" + Sum_Particle + " create keep");
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_sum_merged+files[i]);
 }
 if(C3 == 1){
 run("Merge Channels...", "c1=" + Max_Cells + " c2=" + Max_Particle + " c3=" + Max_PM + " create keep"); //c1red;c2green;c3blue
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_max_merged+files[i]);
 run("Merge Channels...", "c1=" + Sum_Cells + " c2=" + Sum_Particle + " c3=" + Sum_PM + " create keep");
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_sum_merged+files[i]);
 }
 
 create_mask_Particle(Max_Particle);
 run("Set Measurements...", "area mean min centroid perimeter bounding shape feret's integrated skewness kurtosis limit display redirect=["+ Sum_Particle +"] decimal=3");
 run("Analyze Particles...", "size="+area_L_cutoff_Particle+"-"+area_M_cutoff_Particle+" exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[i]+'-ROIset_Particle.zip');
 ROI_measure("ROI Manager");
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Particle", true);
close("*");
close("Results");
close("Log");

CellChannel = getBoolean("Analyze Cells channel?");
if(CellChannel == 1){
for (j=0; j<files.length; j++) {
 print("\\Update0:Cells_processing image: " + j+1 + " of " + files.length);

 open(input+files[j]);
 Filename = clean_title(files[j]);
 rename(Filename);

 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 if(C3 == 1){
 PM = PM_C + Filename;
 }
 Sum_Particle = "SUM_" + Particle;
 Sum_Cells = "SUM_" + Cells_2;
 Max_Particle = "MAX_" + Particle;
 Max_Cells = "MAX_" + Cells_2;

 create_Zprojections(Filename);
 create_mask_Cells(Sum_Cells);
 run("Set Measurements...", " area mean min centroid bounding shape limit display redirect=["+ Sum_Cells +"] decimal=3");
 run("Analyze Particles...", "size="+area_L_cutoff_Cell+"-"+area_M_cutoff_Cell+" circularity=0.6-1.00 exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[j]+'-ROIset_Cell.zip');
 ROI_measure("ROI Manager");
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Cells", true);
close("*");
close("Results");
close("Log");
}

if(C3 == 1){
//PhaseModulator particle analysis
for (j=0; j<files.length; j++) {
 print("\\Update0:PhaseModulator_processing image: " + j+1 + " of " + files.length);

 open(input+files[j]);
 Filename = clean_title(files[j]);
 rename(Filename);

 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 PM = PM_C + Filename;
 Sum_Particle = "SUM_" + Particle;
 Sum_Cells = "SUM_" + Cells_2;
 Sum_PM = "SUM_" + PM;
 Max_Particle = "MAX_" + Particle;
 Max_Cells = "MAX_" + Cells_2;
 Max_PM = "MAX_" + PM;

 create_Zprojections(Filename);
 create_mask_PM(Max_PM);
 run("Set Measurements...", "area mean min centroid perimeter bounding shape feret's integrated skewness kurtosis limit display redirect=["+ Sum_PM +"] decimal=3");
 run("Analyze Particles...", "size="+area_L_cutoff_PM+"-"+area_M_cutoff_PM+" exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[j]+'-ROIset_PM.zip');
 ROI_measure("ROI Manager");  
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "PhaseModulator", true);
close("*");
close("Results");
close("Log");
}

if(CellChannel == 1){
Colocalization1 = getBoolean("Particle/Cell analysis?");
if (Colocalization1 == 1) {
//Object-based colocalization test, determining which particles belong to which cells.
for (m=0; m<files.length; m++) {
 print("\\Update0:Determining intersect Particle-Cell_processing image: " + m+1 + " of " + files.length);
 open(input+files[m]);
 Filename = clean_title(files[m]);
 rename(Filename);

 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 if(C3 == 1){
 PM = PM_C + Filename;
 }
 Sum_Particle = "SUM_" + Particle;
 Sum_Cells = "SUM_" + Cells_2;
 Max_Particle = "MAX_" + Particle;
 Max_Cells = "MAX_" + Cells_2;
 Mask_Particle = Max_Particle + "-1";
 Mask_Cells = Sum_Cells + "-1";

 create_Zprojections(Filename);
 create_mask_Cells(Sum_Cells);
 create_mask_Particle(Max_Particle);

 //Calculate intersect between objects detected in both channels
 imageCalculator("AND create", Mask_Cells, Mask_Particle);
 Intersect = getTitle();
 run("Set Measurements...", "area mean min centroid bounding perimeter shape feret's integrated skewness kurtosis limit display redirect="+Sum_Particle+" decimal=3");
 run("Analyze Particles...", "size="+area_L_cutoff_Particle+"-"+area_M_cutoff_Particle+" exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[m]+'-ROIset_Coloc_ParticleCell.zip');
 ROI_measure("ROI Manager");
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Coloc_ParticleCell", true);
close("*");
close("Results");
close("Log");
print("Analysis finished.");
}

Imagingsetup = getBoolean("Soluble fraction measurement?");
if (Imagingsetup == 1 ) {
//Measure soluble protein fraction
for (l=0; l<files.length; l++) {
 print("\\Update0: Measuring soluble fraction_ParticleChannel_Processing image " + l+1 + " of " + files.length);
 open(input+files[l]);
 Filename = clean_title(files[l]);
 rename(Filename);

 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 if(C3 == 1){
 PM = PM_C + Filename;
 }
 Sum_Particle = "SUM_" + Particle;
 Sum_Cells = "SUM_" + Cells_2;
 Max_Particle = "MAX_" + Particle;
 Max_Cells = "MAX_" + Cells_2;
 Mask_Particle = Max_Particle + "-1";
 Mask_Cells = Sum_Cells + "-1";

 create_Zprojections(Filename);
 create_mask_Cells(Sum_Cells);
 create_mask_Particle(Max_Particle);
 run("Dilate");

 imageCalculator("AND create", Mask_Cells, Mask_Particle);
 Intersect = getTitle();
 imageCalculator("Difference create", Mask_Cells, Intersect);
 Soluble = getTitle();
 run("Set Measurements...", "area mean min centroid bounding integrated skewness kurtosis limit display redirect="+Sum_Particle+" decimal=3");
 run("Analyze Particles...", "size=2.5-"+area_M_cutoff_Cell+" exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[l]+'-ROIset_soluble.zip');
 ROI_measure("ROI Manager");
 }
}
Table.deleteColumn("MinThr");
Table.deleteColumn("MaxThr");
Table.update;
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Soluble", true);
close("*");
close("Results");
close("Summary");
close("Log");
print("Analysis finished.");
}
}

if(C3 == 1){
Colocalization2 = getBoolean("Particle_PhaseModulator object-based coloc analysis?");
if (Colocalization2 == 1) {
for (z=0; z<files.length; z++) {
 print("\\Update0:Determining Intersect Particle-PhaseModulator_processing image: " + z+1 + " of " + files.length);
 open(input+files[z]);
 Filename = clean_title(files[z]);
 rename(Filename);

 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename;
 Cells = Cell_C + Filename;
 Cells_2 = Cells + "-1";
 PM = PM_C + Filename;
 Sum_Particle = "SUM_" + Particle;
 Sum_PM = "SUM_" + PM;
 Max_Particle = "MAX_" + Particle;
 Max_PM = "MAX_" + PM;
 Mask_Particle = Max_Particle + "-1";
 Mask_PM = Max_PM + "-1";

 create_Zprojections(Filename);
 create_mask_Particle(Max_Particle);
 create_mask_PM(Max_PM);

 imageCalculator("AND create", Mask_PM, Mask_Particle);
 IntersectParticlePM = getTitle();
 run("Set Measurements...", "area mean min centroid bounding perimeter shape feret's integrated skewness kurtosis limit display redirect="+Sum_Particle+" decimal=3");
 run("Analyze Particles...", "size=0.01-"+area_M_cutoff_Particle+" exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[z]+'-ROIset_Intersect_ParticlePM.zip');
 ROI_measure("ROI Manager");
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Intersect_ParticlePhaseModulato", true);
close("*");
close("Results");
close("Summary");
close("Log");
print("Analysis finished.");
}
}
}
setBatchMode(false);

function settings (Log) {
print("Input: " + input);
print("Imagetype: " + Imagetype);
print("Particle_C: " + Particle_C);
print("Cell_C: " + Cell_C);
if(C3 == 1){
print("PM_C: " + PM_C);
}
print("LUT_Particle: " + LUT_Particle);
print("LUT_Cell: " + LUT_Cell);
if(C3 == 1){
print("LUT_PM: " + LUT_PM);
}
print("BGSub_Particle: " + BGSub_Particle);
print("BGSub_Cell: " + BGSub_Cell);
if(C3 == 1){
print("BGSub_PM: " + BGSub_PM);
}
print("Crop_x: " + Crop_x);
print("Crop_y: " + Crop_y);
print("Crop_width: " + Crop_width); 
print("Crop_height: " + Crop_height); 
if (Gaussian_Particle == 1) {
print("Gaussian_sigma_Particle: " + Gaussian_sigma_Particle);
}
if (Median_Particle == 1) {
print("Median_radius_Particle: " + Median_radius_Particle);
}
if (Mean_Particle == 1) {
print("Mean_radius_Particle: " + Mean_radius_Particle);
}
if (Minimum_Particle == 1) {
print("Minimum_radius_Particle: " + Minimum_radius_Particle);
}
if (Maximum_Particle == 1) {
print("Maximum_radius_Particle: " + Maximum_radius_Particle);
}
if (UnsharpMask_Particle == 1) {
print("UnsharpMask_radius_Particle: " + UnsharpMask_radius_Particle);
print("UnsharpMask_maskweight_Particle: " + UnsharpMask_maskweight_Particle);
}
if (Tophat_Particle == 1) {
print("Tophat_radius_Particle: " + Tophat_radius_Particle);
}
if (Gaussian_Cell == 1) {
print("Gaussian_sigma_Cell: " + Gaussian_sigma_Cell);
}
if (Median_Cell == 1) {
print("Median_radius_Cell: " + Median_radius_Cell);
}
if (Mean_Cell == 1) {
print("Mean_radius_Cell: " + Mean_radius_Cell);
}
if (Minimum_Cell == 1) {
print("Minimum_radius_Cell: " + Minimum_radius_Cell);
}
if (Maximum_Cell == 1) {
print("Maximum_radius_Cell: " + Maximum_radius_Cell);
}
if (UnsharpMask_Cell == 1) {
print("UnsharpMask_radius_Cell: " + UnsharpMask_radius_Cell);
print("UnsharpMask_maskweight_Cell: " + UnsharpMask_maskweight_Cell);
}
if (Tophat_Cell == 1) {
print("Tophat_radius_Cell: " + Tophat_radius_Cell);
}
if (Gaussian_PM == 1) {
print("Gaussian_sigma_PM: " + Gaussian_sigma_PM);
}
if (Median_PM == 1) {
print("Median_radius_PM: " + Median_radius_PM);
}
if (Mean_PM == 1) {
print("Mean_radius_PM: " + Mean_radius_PM);
}
if (Minimum_PM == 1) {
print("Minimum_radius_PM: " + Minimum_radius_PM);
}
if (Maximum_PM == 1) {
print("Maximum_radius_PM: " + Maximum_radius_PM);
}
if (UnsharpMask_PM == 1) {
print("UnsharpMask_radius_PM: " + UnsharpMask_radius_PM);
print("UnsharpMask_maskweight_PM: " + UnsharpMask_maskweight_PM);
}
if (Tophat_PM == 1) {
print("Tophat_radius_PM: " + Tophat_radius_PM);
}
print("Threshold_Particle: " + Threshold_Particle);
print("Threshold_Cell: " + Threshold_Cell);
if(C3 == 1){
print("Threshold_PM: " + Threshold_PM);
}
print("area_L_cutoff_Particle: " + area_L_cutoff_Particle);
print("area_M_cutoff_Particle: " + area_M_cutoff_Particle);
print("area_L_cutoff_Cell: " + area_L_cutoff_Cell);
print("area_M_cutoff_Cell: " + area_M_cutoff_Cell);
if(C3 == 1){
print("area_L_cutoff_PM: " + area_L_cutoff_PM);
print("area_M_cutoff_PM: " + area_M_cutoff_PM);
}
}

function ImageFilesOnlyArray (arr) {
	//pass array from getFileList through this e.g. NEWARRAY = ImageFilesOnlyArray(NEWARRAY);
	setOption("ExpandableArrays", true);
	f=0;
	files = newArray;
	for (i = 0; i < arr.length; i++) {
		if(endsWith(arr[i], Imagetype)) {
			files[f] = arr[i];
			f=f+1;
		}
	}
	arr = files;
	arr = Array.sort(arr);
	return arr;
}

function clean_title(imagename){
	nl=lengthOf(imagename);
	nl2=nl-3;
	Sub_Title=substring(imagename,0,nl2);
	Sub_Title=replace(Sub_Title, "(","_");
	Sub_Title=replace(Sub_Title, ")","_");
	Sub_Title=replace(Sub_Title, "-","_");
	Sub_Title=replace(Sub_Title, "+","_");
	Sub_Title=replace(Sub_Title, " ","_");
	Sub_Title=replace(Sub_Title, ".","");
	Sub_Title=replace(Sub_Title, "_R3D_D3D","");
	Sub_Title=Sub_Title;
	return Sub_Title;
}

function create_Zprojections (Filename) {
 run("Scale Bar...", "width=5 height=8 font=30 color=White background=None location=[Lower Right] bold overlay label");
 run("Split Channels");
//ParticleChannel
 selectWindow(Particle);
 run(LUT_Particle);
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Subtract Background...", "rolling="+BGSub_Particle+" stack");
 run("Z Project...", "projection=[Sum Slices]");
 run(LUT_Particle);
 selectWindow(Particle);
 run("Z Project...", "projection=[Max Intensity]");
 //CellsChannel
 selectWindow(Cells);
 run("Duplicate...", "duplicate");
 selectWindow(Cells_2);
 run(LUT_Cell);
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Subtract Background...", "rolling="+BGSub_Cell+" stack");
 run("Z Project...", "projection=[Sum Slices]");
 run(LUT_Cell);
 selectWindow(Cells_2);
 run("Z Project...", "projection=[Max Intensity]");
 if(C3 == 1){
 //PMChannel
 selectWindow(PM);
 run(LUT_PM);
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Subtract Background...", "rolling="+BGSub_PM+" stack");
 run("Z Project...", "projection=[Sum Slices]");
 run(LUT_PM);
 selectWindow(PM);
 run("Z Project...", "projection=[Max Intensity]");
 }
}

function create_mask_Particle (Max_Particle) {
 selectWindow(Max_Particle);
 run("Duplicate...", " ");
 if (Gaussian_Particle == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_Particle+"");
 }
 if (Median_Particle == 1 ) {
 	 run("Median...", "radius="+Median_radius_Particle+"");
 }
 if (Mean_Particle == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_Particle+"");
 }
 if (Minimum_Particle == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_Particle+"");
 }
 if (Maximum_Particle == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_Particle+"");
 }
 if (UnsharpMask_Particle == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_Particle+" mask="+UnsharpMask_maskweight_Particle+"");
 }
 if (Tophat_Particle == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_Particle+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method="+Threshold_Particle+" white");
 run("Convert to Mask");
 if (Maximum_Particle == 1 ) {
 	  run("Erode");
 }
}

function create_mask_Cells (Sum_Cells) {
 selectWindow(Sum_Cells);
 run("Duplicate...", " ");
 if (Gaussian_Cell == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_Cell+"");
 }
 if (Median_Cell == 1 ) {
 	 run("Median...", "radius="+Median_radius_Cell+"");
 }
 if (Mean_Cell == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_Cell+"");
 }
 if (Minimum_Cell == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_Cell+"");
 }
 if (Maximum_Cell == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_Cell+"");
 }
 if (UnsharpMask_Cell == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_Cell+" mask="+UnsharpMask_maskweight_Cell+"");
 }
 if (Tophat_Cell == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_Cell+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method="+Threshold_Cell+" white");
 run("Convert to Mask");
// run("Dilate");
 run("Fill Holes");
 run("Watershed");
 // run("Erode");
}

if(C3 == 1){
function create_mask_PM (Max_PM) {
 selectWindow(Max_PM);
 run("Duplicate...", " ");
 if (Gaussian_PM == 1 ) {
 	 run("Gaussian Blur...", "sigma="+Gaussian_sigma_PM+"");
 }
 if (Median_PM == 1 ) {
 	 run("Median...", "radius="+Median_radius_PM+"");
 }
 if (Mean_PM == 1 ) {
 	 run("Mean...", "radius="+Mean_radius_PM+"");
 }
 if (Minimum_PM == 1 ) {
 	 run("Minimum...", "radius="+Minimum_radius_PM+"");
 }
 if (Maximum_PM == 1 ) {
 	 run("Maximum...", "radius="+Maximum_radius_PM+"");
 }
 if (UnsharpMask_PM == 1 ) {
 	 run("Unsharp Mask...", "radius="+UnsharpMask_radius_PM+" mask="+UnsharpMask_maskweight_PM+"");
 }
 if (Tophat_PM == 1 ) {
 	 run("Top Hat...", "radius="+Tophat_radius_PM+"");
 }
 setOption("ScaleConversions", true);
 run("8-bit");
 run("Auto Threshold", "method="+Threshold_PM+" white");
 run("Convert to Mask");
 if (Maximum_PM == 1 ) {
 	  run("Erode");
}
}
}

function ROI_measure (rois) {
 //loop through the ROI Manager
 s = roiManager('count');
 for (i = 0; i < s; i++) {
    roiManager('select', i);
	roiManager("measure");
}
 roiManager("Show All");
 roiManager("Delete");
 roiManager("Reset");
}

function clean_results (Results) {
 Table.deleteColumn("AR");
 Table.deleteColumn("Round");
 Table.deleteColumn("Solidity");
 Table.deleteColumn("MinThr");
 Table.deleteColumn("MaxThr");
 Table.update;
}
