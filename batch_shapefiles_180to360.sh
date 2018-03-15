#!/bin/bash
# reprojects a directory of .shp files from 180 180 WGS84 to 0 360 WGS84

#shapefile_dirs=$1
dest_dir=$1
join_name=$2

for FILE in *.shp
do
 echo "Transforming $FILE file..."
 FILE_NAME=`echo $FILE | sed "s/.shp//"`
 FILENEW=`echo $FILE | sed "s/.shp/_new.shp/"`
 FILEPART1=`echo $FILE | sed "s/.shp/_part1.shp/"`
 FILEPART2=`echo $FILE | sed "s/.shp/_part2.shp/"`
 FILEPART1_SHIFTED=`echo $FILEPART1 | sed "s/.shp/_shifted.shp/"`
 FILE_0_360=`echo $FILE | sed "s/.shp/_0_360.shp/"`
 tb1_name=`echo $FILEPART1 | cut -d'.' -f1`

 #ogr code
 ogr2ogr ${shapefile_dirs}/$FILENEW ${shapefile_dirs}/$FILE -sql "select cast($join_name as numeric(30,5)) from $FILE_NAME" -overwrite -dialect ogrsql 
 ogr2ogr -f 'ESRI Shapefile' $FILEPART1 $FILENEW -progress -clipsrc -180 -90 0 90 
 ogr2ogr -f 'ESRI Shapefile' $FILEPART2 $FILENEW -progress -clipsrc 0 -90 180 90 
 ogr2ogr -f 'ESRI Shapefile' $FILEPART1_SHIFTED $FILEPART1 -dialect sqlite -sql "SELECT ShiftCoords(geometry,360,0) FROM $tb1_name"
 ogr2ogr -f 'ESRI Shapefile' "${dest_dir}/$FILE_0_360" $FILEPART2 -progress
 NAME=`echo "$FILE_0_360" | cut -d'.' -f1`
 ogr2ogr -f 'ESRI Shapefile' -update -append "${dest_dir}/$FILE_0_360" $FILEPART1_SHIFTED -progress -nln "$NAME"
 #ogr2ogr "${dest_dir}/$FILE_0_360" $FILE_0_360_RAW -dialect sqlite -sql "SELECT ST_Union(Geometry), $join_name FROM $NAME GROUP BY $join_name"

done

rm *part1.shp *part2.shp *shifted.shp 
 
exit
