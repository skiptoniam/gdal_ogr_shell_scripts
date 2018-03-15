#!/bin/bash
# reprojects a tif to 360

for FILE in *.tif
do
 echo "Transforming $FILE ..." 
 FILE1=`echo $FILE | sed "s/.tif/_R.tif/"`
 FILE2=`echo $FILE | sed "s/.tif/_L.tif/"`
 FILE3=`echo $FILE | sed "s/.tif/_360.tif/"`

 gdal_translate -projwin -180 90 0 -90 -a_ullr 180 90 360 -90 $FILE $FILE1 
 gdal_translate -a_srs EPSG:4326 -projwin 0 90 180 -90 -a_ullr -0 90 180 -90 $FILE $FILE2
 gdal_merge.py -of GTiff -o $FILE3 $FILE2 $FILE1 

done

rm *_R.tif *_L.tif

exit


