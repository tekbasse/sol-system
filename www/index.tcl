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
