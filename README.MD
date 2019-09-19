OPT Image Importer
==================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) ![This script was last tested in Nuix 8.0](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-8.0-green.svg)

View the GitHub project [here](https://github.com/Nuix/OPT-Image-Importer) or download the latest release [here](https://github.com/Nuix/OPT-Image-Importer/releases).

# Overview

**Written By:** Jason Wells

This script provides a way to take an OPT image loadfile and import associated images into a Nuix case as PDFs.  The script uses the information in the OPT to:
- Locate images on the file system by their path relative to a specified root path configured through the script settings dialog.
- Determine which images belong together as a document, based on document markers in the OPT.
- Determine an identifier for each document used to match the resulting PDF to an item in the Nuix case.

Images are combined into PDF files using iText, which is a dependency of and distributed with Nuix.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Settings

| Setting | Description |
|---------|-------------|
| **Opticon File** | Path to an OPT load file which will be used to import images. |
| **Temp Directory** | The script creates PDF files from images to load them into Nuix.  This specifies a directory in which the script will create these PDFs. |
| **Delete Temporary PDFs** | Whether intermediate PDFs should be deleted from the temp directory once they have been imported into the Nuix case. |
| **Match Production Set DOCID** | When checked, the script will match identifier in OPT file to items in the case using the search `document-id:OPT_ID_HERE`. |
| **Match Metadata Property** | When checked, the script will match identifier in OPT file to values present in metadata property **DOCID** or **BEGINBATES** present on items. This setting is useful when you have ingested a load file previously and wish to now associate images. |
| **Match GUID** | When checked, the script will match the identifier in the OPT file to item's GUIDs.  This setting is useful when you know the GUID that images should be associated to and have crafted an OPT which demonstrates this association. |

## Volume Paths

An OPT file often refers to images using a relative path.  Each entry in an OPT can have an associated volume.  In turn there can be multiple volumes in a given OPT, each which may have its images in a different base directory.

```
FAKEEMAIL-00000001,VOLUME001,IMAGE\00\000\001\FAKEEMAIL-00000001_0001.tif,Y,,,1
FAKEEMAIL-00000002,VOLUME001,IMAGE\00\000\002\FAKEEMAIL-00000002_0001.tif,Y,,,1
FAKEEMAIL-00000003,VOLUME001,IMAGE\00\000\003\FAKEEMAIL-00000003_0001.tif,Y,,,1
FAKEFILE-00000001,VOLUME002,IMAGE\00\000\001\FAKEFILE-00000001_0001.tif,Y,,,1
FAKEFILE-00000002,VOLUME002,IMAGE\00\000\002\FAKEFILE-00000002_0001.tif,Y,,,1
```

The **Volume Paths** tab allows you to associate the proper base directory with each volume:

![image](https://user-images.githubusercontent.com/11775738/53260708-02626b00-3687-11e9-85f8-bc24aa84e2fc.png)

It is also common to have an OPT file without any volumes:

```
FAKEEMAIL-00000001,,IMAGE\00\000\001\FAKEEMAIL-00000001_0001.tif,Y,,,1
FAKEEMAIL-00000002,,IMAGE\00\000\002\FAKEEMAIL-00000002_0001.tif,Y,,,1
FAKEEMAIL-00000003,,IMAGE\00\000\003\FAKEEMAIL-00000003_0001.tif,Y,,,1
FAKEEMAIL-00000004,,IMAGE\00\000\004\FAKEEMAIL-00000004_0001.tif,Y,,,1
FAKEEMAIL-00000005,,IMAGE\00\000\005\FAKEEMAIL-00000005_0001.tif,Y,,,1
```

When this is the case, you still need to add an entry to the **Volume Paths** table to specify a base directory, but you may leave the `Volume` value blank.

![image](https://user-images.githubusercontent.com/11775738/53260852-6e44d380-3687-11e9-8d30-ae6b8ada20be.png)

## Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the scripts.

# License

```
Copyright 2019 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
