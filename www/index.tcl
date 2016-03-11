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

set results "<pre>"
foreach b $p_list {
    append results "${b}: "
    set i 0
    set i_list [list x y z]
    foreach dim $bodies_larr($b) {
        append results "[lindex $i_list $i]=${dim}"
        incr i
    }
    append results "\n\n"
}
append results "</pre>"
