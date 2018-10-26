#!/usr/bin/env python

"""
	This script will convert an analyser XML file from osmose-backend to a GeoJSON

	The variables are as follows:
		xmlDir:	The directory which contains the xml files		
"""

import json
import sys
import os
import re
from lxml import etree as et
from bz2 import BZ2File

# Get directory where files exist
xmlDir = sys.argv[1]

# Loop through all Files
for subdir, dirs, files in os.walk(xmlDir):
	for file in files:
		ext = os.path.splitext(file)[-1].lower()
		if ext == ".bz2":
			# Get all error nodes from XML and export to GeoJSON
			print "Extracting " + file
			path = os.path.join(xmlDir, file)
			with BZ2File(path) as xml_file:
				tree = et.parse(xml_file)
				root = tree.getroot()				
				childCount = len(root.getchildren())

				if childCount == 0:
					print file + " is empty"
				else:
					analyser = root[0]

					featureList = []
					osmoseID = 0

					errItem = -1

					for child in analyser:
						errGeom = {}
						errClass = child.attrib
						errProps = {}
						if 'item' in child.attrib.keys():
							errItem = child.attrib['item']
						if 'class' in child.attrib.keys():
							errProps['class'] = child.attrib['class']
						for c in child:
							validFeature = False
							if c.tag == 'location':
								errGeom["type"] = "Point"
								errGeom["coordinates"] = [float(c.attrib["lon"]), float(c.attrib["lat"])]
								validFeature = True
							else:
								if len(list(c)) > 0:
									for subc in c:
										if 'k' in subc.attrib.keys() and 'v' in subc.attrib.keys():
											errProps[subc.attrib['k']] = subc.attrib['v']
										else:
											for key, value in c.attrib.items():
												errProps[key] = value
								else:
									for key, value in c.attrib.items():
										errProps[key] = value
							errProps["osmoseID"] = osmoseID
							osmoseID += 1
							err={"type":"Feature","properties":errProps,"geometry":errGeom}
							if validFeature:
								featureList.append(err)

					data = {"type":"FeatureCollection","features":featureList}
					
					gjName = re.sub('\..*','',file)
					gjName = gjName if errItem == -1 else gjName + "_" + str(errItem)
					gjFile = os.path.join(xmlDir, gjName + '.geojson')
					f = open(gjFile, 'w+')
					f.write(json.dumps(data))
					print "Created " + gjName + '.geojson'
					f.close()

print "Complete"
