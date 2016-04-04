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
    j2000_time
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
    set alpha_0 [lindex $table6_larr(Sun) 0]
    set alpha_dot [lindex $table6_larr(Sun) 1]
    set delta_0 [lindex $table6_larr(Sun) 2]
    set delta_dot [lindex $table6_larr(Sun) 3]
    set w_cap_0 [lindex $table6_larr(Sun) 4]
    set w_cap_per_day [lindex $table6_larr(Sun) 5]
    #set t_j2000 \[ssk::days_since_j2000 $yyyymmdd\]
    set days_since_j2000 [expr { $j2000_time - 2451545.0 } ]
    set t_cap [expr { $days_since_j2000 / 36525. } ]
    set alpha [expr { $alpha_0 + $alpha_dot * $t_cap } ]
    set delta [expr { $delta_0 + $delta_dot * $t_cap } ]
    set w_cap [expr { $w_cap_0 + $w_cap_per_day * $days_since_j2000 } ]
    while { $w_cap < 0. } {
        set w_cap [expr { $w_cap + 360. } ]
    }
    while { $w_cap > 360. } {
        set w_cap [expr { $w_cap - 360. } ]
    }


    # Solar equator is the plane defined as perpendicular (orthogonal) to a polar oriented vector
    # given a vector N1,N2,N3, plane is equation N1*x + N2*y + N3*z = 0

    # get position of Earth in x y z coordinates

    # Since Sun is at origin (0,0,0), the angle of the line that intersects the Solar equatorial plane
    # is the solar latitude of Earth at Zenith if observer is at Sun.

    
    # given a plane with perpenicular vector from origin to N1,N2,N3, and a line
    # from origin to U1,U2,U3
    # latitude angle =
    #    arcsin(  ( N1*U1 + N2*U2 + N3*U3 ) /
    #           ( sqrt( pow(N1,2) + pow(N2,2) + pow(N3,2) ) * sqrt(pow(u1,2)+pow(u2,2)+pow(u3,2) ) ) )
    # geometry reference: http://www.vitutor.com/geometry/distance/line_plane.html

    return $earth_sol_eq_angle
}

