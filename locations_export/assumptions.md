#### Locations spreadsheet will be created in Excel and saved as .csv
#### The First column is the list of the top administrative division, in the caseof Uganda, the districts
#### There cannot be two different 'districts' in a country with the same name. This effect trickles down at all levels
#### The first row of the spreadsheet will be taken as a title row
#### The reporting level (the same as the one the shape files in geoserver represent) must be passed into the script. Its value should be the 0-based index of the column that contains the entries for this level. For instance, if column 2 has counties and counties is the reporting level, the first argument passed to the script should be 2
**** Demo the fact that if you have a subcounty called 'Yei' in two different counties 'Kajo-Keji' and 	'Lainya', the script will consider onlyone Yei, the one in Kajo-Keji, and all villages attached to the second Yei (the child of Lainya) will be attached to the Yei in Kajo-Keji. Therefore, Lainya will not have any children. We need to fix this when we are getting unique cells in a column
