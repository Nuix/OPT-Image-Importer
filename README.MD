OPT Image Importer
==================

![Last tested in Nuix 7.6](https://img.shields.io/badge/Nuix-7.6-green.svg)

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

## Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the scripts.

# License

```
Copyright 2018 Nuix

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