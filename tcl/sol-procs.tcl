#/sol-system/tcl/sol-procs.tcl
ad_library {

    Sol System package procedures
    @creation-date 3 Apr 2016
    @cvs-id $Id:
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/sol-system
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

# These are calculations about the Sun

namespace eval ::ssk {}

ad_proc -public ssk::sol_earth_latitude {
    time_utc
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    Finds the angle of the Earth above or below the Solar equatorial plane.
} {
    # Sun is at origin (0,0,0)
    # get Solar pole orientation
    # Solar pole is given as Right Ascention, Declination in Celestial Sphere coordinates (Geo-equatorial)
    # ::ssk::table6_larr(Sun)
    # table6 variable order: alpha_0 alpha_dot delta_0 delta_dot w_cap_0 w_cap
    # where
    #        alpha_0       position of the North pole in Right Ascension ( degrees ) 
    #        delta_0       position of the North pole in Declination ( degrees )
    #        alpha_dot     change in Right Ascension position ( degrees per century J2000 )
    #        detla_dot     change in Declination position ( degrees per century J2000 )
    #        w_cap_0       position of the prime meridian at GEI J2000 ( degrees )
    #        w_cap         change in position ( degrees per day )
    variable ::ssk::table6_larr
    variable ::ssk::km_per_au
    variable ::ssk::180perpi
    set alpha_0 [lindex $table6_larr(Sun) 0]
    set alpha_dot [lindex $table6_larr(Sun) 1]
    set delta_0 [lindex $table6_larr(Sun) 2]
    set delta_dot [lindex $table6_larr(Sun) 3]
    set w_cap_0 [lindex $table6_larr(Sun) 4]
    set w_cap_per_day [lindex $table6_larr(Sun) 5]
    set days_since_j2000 [ssk::days_since_j2000 $time_utc]
    #set days_since_j2000 \[expr { $j2000_time - 2451545.0 } \]
    set t_cap [expr { $days_since_j2000 / 36525. } ]
    set alpha [expr { $alpha_0 + $alpha_dot * $t_cap } ]
    set delta [expr { $delta_0 + $delta_dot * $t_cap } ]
    set w_cap [expr { $w_cap_0 + $w_cap_per_day * $days_since_j2000 } ]
    set w_cap [ssk::unwind $w_cap 0. 360.]


    # Solar equator is the plane defined as perpendicular (orthogonal) to a polar oriented vector
    # given a vector N1,N2,N3, plane is equation N1*x + N2*y + N3*z = 0

    # convert polar coordinates of sol's pole coordinates (in Geo RA, Dec) to Cartesian J2000
    # Let's assume r is radius of Sol.
    set r_au [expr { 695700. / $km_per_au } ]
  
    # using spherical polar coordinates to Cartesian transformations,
    # where theta = 90 degrees - Dec angle, thus sin(theta) becomes cos(Dec Angle):
    # x = r * cos( Dec angle ) * cos ( Right accension angle)
    # y = r * cos( Dec angle ) * sin ( righ accension angle )
    # z = r * sin( Dec angle )
    set cos_dec_angle [expr { cos( $delta / $180perpi ) } ]
    set x_n_au [expr { $r_au * $cos_dec_angle * cos( $alpha / $180perpi ) } ]
    set y_n_au [expr { $r_au * $cos_dec_angle * sin( $alpha / $180perpi ) } ]
    set z_n_au [expr { $r_au * sin( $delta / $180perpi ) } ]

    # get position of Earth in x y z coordinates
    ssk::pos_kepler $time_utc Earth e_larr 0
    # Since Sun is at origin (0,0,0), the angle of the line that intersects the Solar equatorial plane
    # is the solar latitude of Earth at Zenith if observer is at Sun.
    # A line through origin is defined by delta X + delta Y + delta Z = 0, or since origin is 0,0,0:
    set x_e_au [lindex $e_larr 0]
    set y_e_au [lindex $e_larr 1]
    set z_e_au [lindex $e_larr 2]
    
    # given a plane with perpenicular vector from origin to N1,N2,N3, and a line
    # from origin to U1,U2,U3
    # latitude angle =
    #    arcsin(  ( N1*U1 + N2*U2 + N3*U3 ) /
    #           ( sqrt( pow(N1,2) + pow(N2,2) + pow(N3,2) ) * sqrt(pow(u1,2)+pow(u2,2)+pow(u3,2) ) ) )
    # geometry reference: http://www.vitutor.com/geometry/distance/line_plane.html
    # (Here N1,N2,N3 = x_n_au,y_n_au,z_n_au  and U1,U2,U3 = x_e_au,y_e_au,z_e_au )
    set solar_lat_rad [expr { asin( ( $x_n_au * $x_e_au + $y_n_au * $y_e_au + $z_n_au * $z_e_au ) / ( sqrt( pow($x_n_au,2) + pow($y_n_au,2) + pow($z_n_au,2) ) * sqrt( pow($x_e_au,2) + pow($y_e_au,2) + pow($z_e_au,2) ) ) ) } ]
    set solar_lat_deg [expr { $solar_lat_rad * $180perpi } ]

    return $solar_lat_deg
}


ad_proc -public ssk::earth_sol_latitude {
    time_utc
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    Finds the position of the Sun (Right Ascention and Declination) in the celestial sphere and other related info
    Returns list: RA (hours), DEC (degrees), apparent arc diameter (degrees), Earth-Sun distance (AU)
} {
    variable ::ssk::180perpi
    ## following are notes originally from:
    ##  USNO Astronomical Applications Dept
    ##  Approximate Solar Coordinates page
    ##  retrieved from http://aa.usno.navy.mil/faq/docs/SunApprox.php

    ## D = JD - 2451545.0
    # see
    set days_since_j2000 [ssk::days_since_j2000 $time_utc]
    #set days_since_j2000 [expr { $j2000_time - 2451545.0 } ]

    #Then compute

    # Mean anomaly of the Sun:
    # g = 357.529 + 0.98560028 D
    set g_deg [expr { 357.529 + 0.98560028 * $days_since_j2000 } ]

    # Mean longitude of the Sun:
    # q = 280.459 + 0.98564736 D
    set q_deg [expr { 280.459 + 0.98564736 * $days_since_j2000 } ]

    # Geocentric apparent ecliptic longitude
    # of the Sun (adjusted for aberration):
    # L = q + 1.915 sin g + 0.020 sin 2g
    # where all the constants (therefore g, q, and L) are in degrees. 

    # It may be necessary or desirable to reduce g, q, and L to the range 0 to 360 degrees
    set q_deg [ssk::unwind $q_deg 0. 360.]
    set g_deg [ssk::unwind $g_deg 0. 360.]
    set l_deg [expr { $q_deg + 1.915 * sin( $g_deg / $180perpi )  + 0.020 sin( 2. * $g_deg / $180perpi) } ]
    set l_deg [ssk::unwind $l_deg 0. 360.]


    # The Sun's ecliptic latitude, b, can be approximated by b=0. 
    set b 0.
    # The distance of the Sun from the Earth, R, in astronomical units (AU), can be approximated by
    # R = 1.00014 - 0.01671 *cos (g ) - 0.00014 * cos(2*g)
    set r_au [expr { 1.00014 - 0.01671 * cos($g_deg / $180perpi ) - 0.00014 * cos( 2. * $g_deg / $180perpi) } ]
    # Once the Sun's apparent ecliptic longitude, L, has been computed, 
    # the Sun's right ascension and declination can be obtained. 

    # First compute the mean obliquity of the ecliptic, in degrees:
    # e = 23.439 - 0.00000036 D
    set e_deg [expr { 23.439 - 0.00000036 * $days_since_j2000 } ]
    #Then the Sun's right ascension, RA, and declination, d, can be obtained from
    #tan RA = cos e sin L / cos L
    #sin d = sin e sin L
    set sin_l [expr { sin( $l_deg / $180perpi ) } ]
    set sol_ra_deg [expr { $180perpi * atan2( cos( $e_deg / $180perpi) * $sin_l , cos( $l_deg / $180perpi ) ) } ]
    set sol_dec_deg [expr { $180perpi * asin( sin( $e_deg / $180perpi) * $sin_l ) } ]
    
    #RA is always in the same quadrant as L. 
    # If the numerator and denominator on the right side of the expression for RA are used in a double-argument arctangent function
    # (e.g., "atan2"), the proper quadrant will be obtained. 

    # If RA is obtained in degrees, it can be converted to hours by dividing by 15. 
    # RA is conventionally reduced to the range 0 to 24 hours
    set sol_ra_hours [expr { $sol_ra_deg / 15. } ]
    # Other quantities can also be obtained. 
    # The Equation of Time, EqT, apparent solar time minus mean solar time, can be computed from
    # EqT = q/15 - RA
    # where Eqt and RA are in hours and q is in degrees. 
    # More at http://aa.usno.navy.mil/faq/docs/eqtime.php
    
    # The angular semidiameter of the Sun, SD, in degrees, is simply
    # SD = 0.2666 / R   or between 0.52 and 0.545 degrees of arc
    set sol_diameter_deg [expr { 0.2666 / $r_au } ]
    #This algorithm is essentially the same as that found on page C5 of The Astronomical Almanac; 
    # a few constants have been adjusted above to extend the range of years for which the algorithm is valid.
    ## end of quoted material from unso sol page.
    return [list $sol_ra_hours $sol_dec_deg $sol_diameter_deg $r_au]
}


ad_proc -public ssk::unwind {
    deg
    {min "0."}
    {max "360."}
} {
    Rotates angle until within range 0 to 360 (or -180 to 180).. etc.
} {
    set min [expr { $min + 0. } ]
    set max [expr { $max + 0. } ]
    # catch spin condition, return unchanged
    if { $max > $min } {
        set range [expr { $max - $min } ]
        
        while { $deg < $min } {
            set deg [expr { $deg + $range } ]
        }
        while { $deg > $max } {
            set deg [expr { $deg - $range } ]
        }
    }
    return $deg
}
