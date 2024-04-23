# Look Transforms #

ACES Look Transforms are also known by the acronym "LMTs".

The following is a very brief overview of Look Transforms (LMTs). More information can be found in the [ACES Documentatoin](docs.acescentral.com).

There is also a multi-part series of posts on ACESCentral that detail the basic use and process for creating simple LMTs:

* [LMTs Part 1](http://acescentral.com/t/lmts-part-1-what-are-they-and-what-can-they-do-for-me/790 "LMTs Part 1")
* [LMTs Part 2](http://acescentral.com/t/lmts-part-2-how-do-they-work-and-how-are-they-made/1203 "LMTs Part 2")
* [LMTs Part 3](http://acescental.com/t/lmts-part-3-how-do-they-work-and-how-are-they-made-continued/1206 "LMTs Part 3")
* [LMTs Part 4](http://acescentral.com/t/lmts-part-4-how-do-they-work-and-how-are-they-made-continued/1217 "LMTs Part 4")

### What Are They?

Look Transforms (LMTs) provide a means to apply a variety of looks to ACES images. LMTs can be used to change the look from the default associated with an Output Transform to a customized look that one might want to use over and over again as a different starting point. 

LMTs are defined as ACES to ACES transformations, though in practice can convert internally to other encodings more appropriate for applying certain color operations. In the simple diagram below, the ACES data resulting after the application of an LMT is designated as ACES' ("ACES prime"). ACES' data is then viewed through the RRT and an ODT as illustrated in the diagram below.  

                |---------|            |---------|
                |         |            |         |
      ACES ---->|  Look   |--- ACES'-->| Output  |--->   display 
                |Transform|            |Transform|     code values
                |         |            |         |
                |---------|            |---------|


### Building the Included LMT

The example LMT included with this package is an "empirical" Look Transform derived using the Inverse Output Transform. In this example, only a tonescale is used because we are just trying to make a 1D look-up table to match the contrast of v1. However, this same method can be utilized in three dimensions to create a 3D LUT to brute force match a full  existing look such as a Print Film Emulation or a custom look that was created outside of the ACES system.

The file `Look.Academy.Contrast_of_ACESv1.ctl` was created to provide a means to match the neutral tone scale contrast of the RRT/ODT system that shipped with ACES v1.x.  To create it, a ramp of ACES values were processed through the v1.3 RRT and the v1.3 P3D60 ODT. The resulting P3 code values were then processed through the Inverse Output Transform for P3D60 from the current ACES release. This inverse applied to the output resulted in a corresponding set of ACES' value. The original ACES values and these derived ACES' values become the input and output of a 1D-LUT, to map ACES->ACES'.  The following diagram illustrates the process.

Generation of the LMT to Contrast of ACESv1:

                  |--------|          |--------|
    :- - - :      | RRT    |          | P3D60  |
    : ACES :----->| v1.3   |---OCES-->|  ODT   |---- P3-D60 code values
    :  ||  :      |        |          |  v1.3  |          |
    :  ||  :      |--------|          |--------|          |
    : 1DLUT :                                             |
    :mapping:                                             |
    :  ||   :     |--------|                              |
    :  \/   :     | Current|                              |
    : ACES' :<----| Inverse|<-----------------------------| 
    : - - - :     | Output |
       ::         |--------|
       ::
       ::
       :: = = = = = ::
                    ::
                    ::
                    \/
                |--------|           |---------|
                |  LMT   |           |Current  |
      ACES ---->|Contrast|---ACES'-->|Output   |--> code values
                | of v1  |           |Transform|
                |--------|           |---------|


### Application of LMTs to ACES data ###

Care should be taken when using LMTs as a carelessly designed LMT transform can inadvertently limit the dynamic range of the ACES' data. This is particularly true when using empirical LMTs constructed without considering what happens to data received outside of the space used to construct it. The inherent dynamic range limitation associated with the transformation of ACES' data to a set of display code values should be considered. ACES' data created using an empirical LMT might not contain the additional dynamic range usually associated with ACES data.

ACES' data created using an analytic LMT may not have this limitation. If the operator providing the modification does not limit the dynamic range during the transformation from ACES to ACES', then the LMT may preserve the dynamic range associated with the original unaltered ACES data.

## Notes ##

### Contrib directory ###
The `contrib` directory contains community-supplied transforms, provided as-is and may not be optimal. The ACES team may have done minimal testing on these transforms, but please visit [ACESCentral.com](https://community.acescentral.com) to review or leave feedback.

### Note to Implementers ###

#### Implementation Guidelines ####
- **Primary Transforms**: The transforms located in each of the subdirectories of the root directory, with the exception of the `contrib` directory, are a basic subset of possible outputs and should be implemented in all ACES systems. These subdirectories contain the standardized, validated transforms necessary for maintaining compatibility and functionality across different platforms and devices.
- **Community Contributed Transforms**: The `contrib` directory contains additional community-supplied transforms. These are considered optional. They may provide useful extensions but vary in their testing and support. It is advisable to evaluate their reliability and suitability for your specific needs before integration.
- **Updates and Maintenance**: Ensure your system includes the most recent updates by regularly incorporating new or revised transforms from the main subdirectories, keeping in line with the latest ACES specifications and industry practices.

## License ##
This project is licensed under the terms of the [LICENSE](./LICENSE.md) agreement.

## Contributing ##
Thank you for your interest in contributing to our project. Before any contributions can be accepted, we require contributors to sign a Contributor License Agreement (CLA) to ensure that the project can freely use your contributions. You can find more details and instructions on how to sign the CLA in the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

## Support ## 
For support, please visit [ACESCentral.com](https://acescentral.com)
