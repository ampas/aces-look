// <ACEStransformID>urn:ampas:aces:transformId:v2.0:Look.Academy.ReferenceGamutCompress.a2.v1</ACEStransformID>
// <ACESuserName>Reference Gamut Compress</ACESuserName>

//
// Gamut compression algorithm to bring out-of-gamut scene-referred values into AP1
//

//
// Usage:
//  This transform is intended to be applied to AP0 data, immediately after the IDT, so
//  that all grading or compositing operations are downstream of the compression, and
//  therefore work only with positive AP1 values.
//
// Note:
//  It is not recommended to bake the compression into VFX pulls, as it may be beneficial
//  for compositors to have access to the unmodified image data.

//
// Input and output: ACES2065-1
//


float max( float a, 
           float b )
{
    if (a > b)
        return a;
    else
        return b;
}

float max_f3( float a[3] )
{
    return max( a[0], max( a[1], a[2]));
}

const Chromaticities AP0 = // ACES Primaries from SMPTE ST2065-1
{
  { 0.73470,  0.26530},
  { 0.00000,  1.00000},
  { 0.00010, -0.07700},
  { 0.32168,  0.33767}
};

const Chromaticities AP1 = // Working space and rendering primaries for ACES 1.0
{
  { 0.713,    0.293},
  { 0.165,    0.830},
  { 0.128,    0.044},
  { 0.32168,  0.33767}
};

const float AP0_2_XYZ_MAT[4][4] = RGBtoXYZ( AP0, 1.0);
const float XYZ_2_AP0_MAT[4][4] = XYZtoRGB( AP0, 1.0);

const float AP1_2_XYZ_MAT[4][4] = RGBtoXYZ( AP1, 1.0);
const float XYZ_2_AP1_MAT[4][4] = XYZtoRGB( AP1, 1.0);

const float AP0_2_AP1_MAT[4][4] = mult_f44_f44( AP0_2_XYZ_MAT, XYZ_2_AP1_MAT);
const float AP1_2_AP0_MAT[4][4] = mult_f44_f44( AP1_2_XYZ_MAT, XYZ_2_AP0_MAT);



/* --- Gamut Compress Parameters --- */
// Distance from achromatic which will be compressed to the gamut boundary
// Values calculated to encompass the encoding gamuts of common digital cinema cameras
const float LIM_CYAN =  1.147;
const float LIM_MAGENTA = 1.264;
const float LIM_YELLOW = 1.312;

// Percentage of the core gamut to protect
// Values calculated to protect all the colors of the ColorChecker Classic 24 as given by
// ISO 17321-1 and Ohta (1997)
const float THR_CYAN = 0.815;
const float THR_MAGENTA = 0.803;
const float THR_YELLOW = 0.880;

// Aggressiveness of the compression curve
const float PWR = 1.2;



// Calculate compressed distance
float compress(float dist, float lim, float thr, float pwr)
{
    float comprDist;
    float scl;
    float nd;
    float p;

    if (dist < thr) {
        comprDist = dist; // No compression below threshold
    }
    else {
        // Calculate scale factor for y = 1 intersect
        scl = (lim - thr) / pow(pow((1.0 - thr) / (lim - thr), -pwr) - 1.0, 1.0 / pwr);

        // Normalize distance outside threshold by scale factor
        nd = (dist - thr) / scl;
        p = pow(nd, pwr);

        comprDist = thr + scl * nd / (pow(1.0 + p, 1.0 / pwr)); // Compress
    }

    return comprDist;
}



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut
) 
{ 
    // Source values
    float ACES[3] = {rIn, gIn, bIn};

    // Convert to ACEScg
    float linAP1[3] = mult_f3_f44(ACES, AP0_2_AP1_MAT);

    // Achromatic axis
    float ach = max_f3(linAP1);

    // Distance from the achromatic axis for each color component aka inverse RGB ratios
    float dist[3];
    if (ach == 0.0) {
        dist[0] = 0.0;
        dist[1] = 0.0;
        dist[2] = 0.0;
    }
    else {
        dist[0] = (ach - linAP1[0]) / fabs(ach);
        dist[1] = (ach - linAP1[1]) / fabs(ach);
        dist[2] = (ach - linAP1[2]) / fabs(ach);
    }

    // Compress distance with parameterized shaper function
    float comprDist[3] = {
        compress(dist[0], LIM_CYAN, THR_CYAN, PWR),
        compress(dist[1], LIM_MAGENTA, THR_MAGENTA, PWR),
        compress(dist[2], LIM_YELLOW, THR_YELLOW, PWR)
    };

    // Recalculate RGB from compressed distance and achromatic
    float comprLinAP1[3] = {
        ach - comprDist[0] * fabs(ach),
        ach - comprDist[1] * fabs(ach),
        ach - comprDist[2] * fabs(ach)
    };

    // Convert back to ACES2065-1
    ACES = mult_f3_f44(comprLinAP1, AP1_2_AP0_MAT);

    // Write output
    rOut = ACES[0];
    gOut = ACES[1];
    bOut = ACES[2];
    aOut = aIn;
}