//------------------------------------------------------------------------
//[PhaseMetrics] image analysis pipeline for quantitative assessment of biomolecular condensate properties - in vitro experiments
//------------------------------------------------------------------------
/*
 *Author : Tessa Bergsma
 *European Research Institute for the Biology of Ageing, University of Groningen
 *Date: May 29, 2023
 *
 *Preprocesses z-stacks, creates maximum and sum projection images with background substraction and analyzes particle properties (e.g. size, shape descriptors such as circularity, and intensity measurements).
 *Offers possibility for measurement of soluble fraction.
 *The multi-channel module analyzes particles in both channels and has the additive functionality to run an object-based colocalization test (determining regions of intersection and non-colocalized regions). 
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

//Parameters
#@ File(label="Input data:", value = "E:/", style= "directory") input
#@ String Imagetype
#@ String (visibility=MESSAGE, value="<html><li>Channel selection_______________________________________________________________________________________________", required=false) msg
#@ String(label="Particle channel", choices={"C1-","C2-","C3-"}, style = "listBox") Particle_C
#@ String(label="PhaseModulator channel", choices={"C1-","C2-","C3-"}, style = "listBox") PM_C
#@ String (visibility=MESSAGE, value="<html><li>Assigning lookup tables (coloring) to channels__________________________________________________________________", required=false) msg1
#@ String(label="ColorLUT_Particle", choices={"Fire","Grays","Ice","Spectrum","3-3-2 RGB","Red","Green","Blue","Cyan","Magenta","Yellow","Red/Green"}, style = "listBox") LUT_Particle
#@ String(label="ColorLUT_PhaseModulator", choices={"Fire","Grays","Ice","Spectrum","3-3-2 RGB","Red","Green","Blue","Cyan","Magenta","Yellow","Red/Green"}, style = "listBox") LUT_PM
#@ String (visibility=MESSAGE, value="<html><li>Assigning “rolling ball” radius for background subtraction _____________________________________________________", required=false) msg2
#@ Integer(label="Background subtraction_Particle", value = 50, style = "spinner") BGSub_Particle 
#@ Integer(label="Background subtraction_PhaseModulator", value = 50, style = "spinner") BGSub_PM
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
#@ boolean(label="Unsharp mask_Particle") UnsharpMask_Particle 
#@ Float(label="Unsharp mask Radius_Particle", style = "spinner", stepSize=0.01, value = 0) UnsharpMask_radius_Particle
#@ Float(label="Unsharp mask MaskWeight_Particle", style = "spinner", stepSize=0.1, value = 0) UnsharpMask_maskweight_Particle
#@ boolean(label="Minimum_Particle") Minimum_Particle 
#@ Float(label="Minimum Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Minimum_radius_Particle
#@ boolean(label="Maximum_Particle") Maximum_Particle 
#@ Float(label="Maximum Radius_Particle", style = "spinner", stepSize=0.01, value = 0) Maximum_radius_Particle
#@ boolean(label="Tophat_Particle") Tophat_Particle
#@ Float(label="Tophat radius_Particle", style = "spinner", stepSize=0.01, value = 0) Tophat_radius_Particle
#@ String (visibility=MESSAGE, value="<html><li>Filtering for phasemodulator channel____________________________________________________________________________", required=false) msg5
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
#@ String (visibility=MESSAGE, value="<html><li>Threshold selection___________________________________________________________________________________________", required=false) msg6
#@ String(label="Thresholding method_Particle", choices={"Otsu","RenyiEntropy","Yen","Moments","Minimum","Maximum","Huang","Huang2","Li","MaxEntropy","Percentile","Shanbhag","Triangle","Intermodes","IsoData","Mean","MinError(I)"}, style = "listBox") Threshold_Particle
#@ String(label="Thresholding method_PhaseModulator", choices={"Otsu","RenyiEntropy","Yen","Moments","Minimum","Maximum","Huang","Huang2","Li","MaxEntropy","Percentile","Shanbhag","Triangle","Intermodes","IsoData","Mean","MinError(I)"}, style = "listBox") Threshold_PM
#@ String (visibility=MESSAGE, value="<html><li>Size cutoffs__________________________________________________________________________________________________", required=false) msg7
#@ Float(label="Area min cutoff_Particle", style="spinner", stepSize=0.01, value=0) area_L_cutoff_Particle
#@ Float(label="Area max cutoff_Particle", style="spinner", stepSize=0.01, value=10000) area_M_cutoff_Particle
#@ Float(label="Area min cutoff_PhaseModulator", style="spinner", stepSize=0.01, value=0) area_L_cutoff_PM
#@ Float(label="Area max cutoff_PhaseModulator", style="spinner", stepSize=0.01, value=0) area_M_cutoff_PM

Imagingsetup = getBoolean("Soluble fraction measurement?");
Channels = getBoolean("Multichannel?");

if (Channels == 0) {
//------------------------------------------------------------------------
// Single-channel module
//------------------------------------------------------------------------
//Create output folders images
File.makeDirectory(input + "/output");
output = input + "/output/";
File.makeDirectory(input + "/output/Montage");
output_threshold_montage = output + "Montage/";
File.makeDirectory(input + "/output/Max");
output_max = output + "Max/";
File.makeDirectory(input + "/output/Sum");
output_sum = output + "Sum/";

//Create output folders results
File.makeDirectory(input + "/output/Results");
output_results = output + "Results/";
File.makeDirectory(input + "/output/ROIs");
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

if (Imagingsetup == 1 ) {
//Measure background fluorescence of full image
for (j=0; j<files.length; j++) {
 print("\\Update0: Measuring soluble fraction_Processing image " + j+1 + " of " + files.length);
 open(input+files[j]);
 Filename = clean_title(files[j]);
 rename(Filename);
 
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
 
 selectWindow(Filename);
 run("Z Project...", "projection=[Max Intensity]");
 Max = getTitle();
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
 run("Dilate");
 run("Dilate");
 run("Invert");
 run("Create Selection");
 roiManager("Add");
 run("Set Measurements...", "area mean min integrated limit display redirect=["+ Sum +"] decimal=3");
 run("Measure");

 if (roiManager("Count") > 0){
 roiManager("select", 0);
 run("Select All");
 roiManager("save", output_rois+files[j]+'-ROIset_soluble.zip');
 roiManager("Deselect");
 roiManager("Delete");
 close();
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
} else if (Channels == 1) { 
//------------------------------------------------------------------------
// Multi-channel module
//------------------------------------------------------------------------
File.makeDirectory(input + "/Output");
output = input + "/Output/";
File.makeDirectory(input + "/Output/Montage");
output_threshold_montage = output + "Montage/";
File.makeDirectory(input + "/Output/Montage/Particle");
output_montage_Particle = output_threshold_montage + "Particle/";
File.makeDirectory(input + "/Output/Montage/PhaseModulator");
output_montage_PhaseModulator = output_threshold_montage + "PhaseModulator/";
File.makeDirectory(input + "/Output/Max");
output_max = output + "Max/";
File.makeDirectory(input + "/Output/Max/Particle");
output_max_Particle = output_max + "Particle/";
File.makeDirectory(input + "/Output/Max/PhaseModulator");
output_max_PhaseModulator = output_max + "PhaseModulator/";
File.makeDirectory(input + "/Output/Max/Merged");
output_max_merged = output_max + "Merged/";
File.makeDirectory(input + "/Output/Sum");
output_sum = output + "Sum/";
File.makeDirectory(input + "/Output/Sum/Particle");
output_sum_Particle = output_sum + "Particle/";
File.makeDirectory(input + "/Output/Sum/PhaseModulator");
output_sum_PhaseModulator = output_sum + "PhaseModulator/";
File.makeDirectory(input + "/Output/Sum/Merged");
output_sum_merged = output_sum + "Merged/";

File.makeDirectory(input + "/output/Results");
output_results = output + "Results/";
File.makeDirectory(input + "/output/ROIs");
output_rois = output + "ROIs/";

settings ("Log");
saveAs("Text", output+"Settings.txt");
close("Text");

input = input + "/";
files = getFileList(input);
files = ImageFilesOnlyArray(files);

setBatchMode(true);
//Particle analysis
for (i=0; i<files.length; i++) {
 print("\\Update0:Particle_processing image: " + i+1 + " of " + files.length);
 
 open(input+files[i]);
 Filename = clean_title(files[i]); //Functions listed at bottom of script
 rename(Filename);
 
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename; 
 PM = PM_C + Filename;
 Sum_PM = "SUM_" + PM;
 Sum_Particle = "SUM_" + Particle;
 Max_PM = "MAX_" + PM;
 Max_Particle = "MAX_" + Particle;
 Mask_Particle = Max_Particle + "-1";
 
 //Creating and saving of max, and sum projections
 create_Zprojections(Filename);
 selectWindow(Sum_Particle);
 run("Duplicate...", " ");
 saveAs("Tiff", output_sum_Particle+files[i]);
 selectWindow(Max_Particle);
 run("Duplicate...", " ");
 saveAs("Tiff", output_max_Particle+files[i]);
 selectWindow(Sum_PM);
 run("Duplicate...", " ");
 saveAs("Tiff", output_sum_PhaseModulator+files[i]);
 selectWindow(Max_PM);
 run("Duplicate...", " ");
 saveAs("Tiff", output_max_PhaseModulator+files[i]);
 
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
 
 //Create merged images using the maximum intensity and sum of slices projections
 run("Merge Channels...", "c1=" + Max_Particle + " c2=" + Max_PM + " create keep");
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_max_merged+files[i]);
 run("Merge Channels...", "c1=" + Sum_Particle + " c2=" + Sum_PM + " create keep");
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 saveAs("Tiff", output_sum_merged+files[i]);
 
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

PM_channel = getBoolean("Analysis of phase modulator particles?");
if (PM_channel == 1) {  
//PhaseModulator channel analysis
for (j=0; j<files.length; j++) {
 print("\\Update0:PhaseModulator_processing image: " + j+1 + " of " + files.length);
 
 open(input+files[j]);
 Filename = clean_title(files[j]);
 rename(Filename);
 
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename; 
 PM = PM_C + Filename;
 Sum_PM = "SUM_" + PM;
 Max_PM = "MAX_" + PM;
 Mask_PM = Max_PM + "-1";

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

Colocalization = getBoolean("Particle_PhaseModulator object-based coloc analysis?");
if (Colocalization == 1) {  
for (m=0; m<files.length; m++) {
 print("\\Update0:Determining intersect Particle-PhaseModulator_processing image: " + m+1 + " of " + files.length);
 open(input+files[m]);
 Filename = clean_title(files[m]);
 rename(Filename);
 
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename; 
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

 //Calculate intersect between objects detected in both channels
 imageCalculator("AND create", Mask_Particle, Mask_PM);
 Intersect = getTitle();
 run("Set Measurements...", "area mean min centroid bounding integrated skewness kurtosis limit display redirect="+Sum_Particle+" decimal=3");
 run("Analyze Particles...", "size=0.015-Infinity exclude add");
 if (roiManager("Count") > 0){
 roiManager("Show All");
 roiManager("save", output_rois+files[m]+'-ROIset_intersect.zip');

 ROI_measure("ROI Manager");
 }
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Intersect", true); 
close("*");
close("Results");
close("Log");

//Determine uncolocalized region
for (n=0; n<files.length; n++) {
print("\\Update0:Determining non-colocalized regions_processing image: " + n+1 + " of " + files.length);
open(input+files[n]);
Filename = clean_title(files[n]);
rename(Filename);
 
makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
run("Duplicate...", "duplicate");
Filename = getTitle();
Particle = Particle_C + Filename; 
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

//Calculate uncolocalized region
imageCalculator("AND create", Mask_Particle, Mask_PM);
Intersect = getTitle();
imageCalculator("Difference create", Mask_Particle, Intersect);
Uncolocalized_area = getTitle();
run("Set Measurements...", "area mean min centroid bounding integrated skewness kurtosis limit display redirect="+Sum_Particle+" decimal=3");
run("Analyze Particles...", "size=0.015-Infinity exclude add");
if (roiManager("Count") > 0){
roiManager("Show All");
roiManager("save", output_rois+files[n]+'-ROIset_uncolocalized_area.zip');
ROI_measure("ROI Manager");
}
}
clean_results("Results");
Ext.xlsx_SaveTableAsWorksheet("Results", output_results+"Results.xls", "Nocolocregion", true); 
close("*");
close("Results");
close("Log");
print("Analysis finished.");
}

if (Imagingsetup == 1 ) {
//Measure background fluorescence of full image/soluble fraction
for (l=0; l<files.length; l++) {
 print("\\Update0: Measuring soluble fraction_ParticleChannel_Processing image " + l+1 + " of " + files.length);
 open(input+files[l]);
 Filename = clean_title(files[l]);
 rename(Filename);
 
 makeRectangle(Crop_x, Crop_y, Crop_width, Crop_height);
 run("Duplicate...", "duplicate");
 Filename = getTitle();
 Particle = Particle_C + Filename; 

 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Split Channels");
 selectWindow(Particle);
 run(LUT_Particle);
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
 run("Subtract Background...", "rolling="+BGSub_Particle+" stack");
 run("Z Project...", "projection=[Sum Slices]");
 run(LUT_Particle);
 Sum_Particle = getTitle();
 
 selectWindow(Particle);
 run("Z Project...", "projection=[Max Intensity]");
 Max = getTitle();
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
 run("Dilate");
 run("Dilate");
 run("Invert");
 run("Create Selection");
 roiManager("Add");
 run("Set Measurements...", "area mean min integrated limit display redirect=["+ Sum_Particle +"] decimal=3");
 run("Measure");

 if (roiManager("Count") > 0){
 roiManager("select", 0);
 run("Select All");
 roiManager("save", output_rois+files[l]+'-ROIset_soluble.zip');
 roiManager("Deselect");
 roiManager("Delete");
 close();
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
setBatchMode(false);

function settings (Log) {
print("Input: " + input);
print("Imagetype: " + Imagetype);
print("Particle_C: " + Particle_C);
print("PM_C: " + PM_C);
print("LUT_Particle: " + LUT_Particle);
print("LUT_PM: " + LUT_PM);
print("BGSub_Particle: " + BGSub_Particle);
print("BGSub_PM: " + BGSub_PM);
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
print("Threshold_PM: " + Threshold_PM);
print("area_L_cutoff_Particle: " + area_L_cutoff_Particle);
print("area_M_cutoff_Particle: " + area_M_cutoff_Particle);
print("area_L_cutoff_PM: " + area_L_cutoff_PM);
print("area_M_cutoff_PM: " + area_M_cutoff_PM);
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
	Sub_Title=replace(Sub_Title, ".","_");
	Sub_Title=replace(Sub_Title, "_R3D_D3D","");
	Sub_Title=Sub_Title;
	return Sub_Title; 
}

function create_Zprojections (images) {
 run("Scale Bar...", "width=5 height=2 location=[Lower Right] horizontal bold hide overlay");
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

function create_mask_Particle (Particle) {
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
 
function create_mask_PM (PM) {
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
 if (Maximum_Particle == 1 ) {
 	  run("Erode");
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