set title "Solar System"
set context [list $title]
#set user_id [ad_conn user_id]
#set instance_id [ad_conn package_id]
#set admin_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege admin]

set test $ssk::180perpi
set p_list $::ssk::planets_list
#set p_list [list 1 2 3]
set date [clock format [clock seconds] -format "%Y%m%d"]

ssk::pos_kepler $date $p_list bodies_larr

set results "<p>for today: $date</p>\n\n"
append results "<table>"
append results "<tr><td>body</td><td>x</td><td>y</td><td>z</td><td>r</td></tr>"
foreach b $p_list {
    append results "<tr><td>${b}</td>"
    set i 0
    set i_list [list x y z]
    set r 0.

    foreach dim $bodies_larr($b) {
        set r [expr { $r + pow( $dim , 2. ) } ]
        #append results "<td>[lindex $i_list $i]=${dim}</td>"
        append results "<td>${dim}</td>"
        incr i
    }
    set r [expr { sqrt( $r ) } ]
    append results "<td>${r} AU</td></tr>"
    append results "\n\n"
}
append results "</table>"

set equinox_vernal "2016-03-20"
set equinox_autumnal "2016-09-22"
set solstice_north "2016-06-20"
set solstice_south "2016-12-21"
set ev [clock scan $equinox_vernal]
set ea [clock scan $equinox_autumnal]
set sn [clock scan $solstice_north]
set ss [clock scan $solstice_south]
set day_s [expr { 24 * 60 * 60 } ]
set ev_minus [expr { $ev - 25 * $day_s } ]
set ev_plus [expr { $ev + 25 * $day_s } ]
set ea_minus [expr { $ea - 25 * $day_s } ]
set ea_plus [expr { $ea + 25 * $day_s } ]
set day_list [list ]
set time_list [list $ev_minus $ev $ev_plus $ea_minus $ea $ea_plus $sn $ss]
foreach time_s $time_list {
    set date [clock format $time_s -f "%Y%m%d"]
    lappend day_list $date
}

#set day_list [list 65 88 115 154 180 206]
#append results "<p>For days 87 +/- 26 and 180 +/- 26, ie [join ${day_list} ","]</p>"

    

append results "<p>What's the angle and size of theoretical current disc at Earth's radius? </p>"

append results "<table>"
append results "<tr><td>date</td><td>x</td><td>y</td><td>z (AU)</td><td>z (km)</td><td>radians</td><td>degrees</td></tr>"

set ii [lindex $::ssk::planets_list 2]
foreach day $day_list {
    # 2 is earth, 0 is Mercury
    ssk::pos_kepler $day 2 earth_larr
    set x [lindex $earth_larr($ii) 0]
    set y [lindex $earth_larr($ii) 1]
    set z [lindex $earth_larr($ii) 2]
    # 149497870.7 km/AU
    set z_km [expr { round( $z * 149597870.7 ) } ]

    # z is in au, convert to degrees for the heck of it
    # arctan (z / r_of_xy) = angle in radians
    set r_xy [expr {  sqrt( pow( $y , 2. ) + pow( $x , 2. ) ) } ]
    set z_rad [expr { atan( $z / $r_xy ) } ]
    set z_deg [expr { $z_rad * $::ssk::180perpi } ]
    append results "<tr><td>$day</td><td>${x}</td><td>${y}</td><td>${z}</td><td>${z_km}</td><td>${z_rad}</td><td>${z_deg}</td></tr>"
}
append results "</table>"

# Let's add a years worth of motion, to get a sense of tracking.
set step [expr { 7 * $day_s } ]
set year_s [expr { round( 365.256 * $day_s ) } ]
set t [expr { $ss - $year_s } ]
append results "<p>A year's worth of Earth's motion</p>"
append results "<table>"
append results "<tr><td>date</td><td>x</td><td>y</td><td>z (AU)</td><td>z (km)</td><td>radians</td><td>degrees</td></tr>"
while { $t < $ss } {
    set t_yyyymmdd [clock format $t -f "%Y%m%d"]
    ssk::pos_kepler $t_yyyymmdd 2 earth_larr
    set x [lindex $earth_larr($ii) 0]
    set y [lindex $earth_larr($ii) 1]
    set z [lindex $earth_larr($ii) 2]
    # 149497870.7 km/AU
    set z_km [expr { round( $z * 149597870.7 ) } ]

    # z is in au, convert to degrees for the heck of it
    # arctan (z / r_of_xy) = angle in radians
    set r_xy [expr { sqrt( pow( $y , 2. ) + pow( $x , 2. ) ) } ]
    set z_rad [expr { atan( $z / $r_xy ) } ]
    set z_deg [expr { $z_rad * $::ssk::180perpi } ]
    # format
    set f "%.5G"
    set x [format $f $x]
    set y [format $f $y]
    set z [format $f $z]
    set z_rad [format $f $z_rad]
    set z_deg [format $f $z_deg]
    append results "<tr><td>${t_yyyymmdd}</td><td>${x}</td><td>${y}</td><td>${z}</td><td>${z_km}</td><td>${z_rad}</td><td>${z_deg}</td></tr>"
    set t [expr { $t + $step } ]
    }
append results "</table>"
