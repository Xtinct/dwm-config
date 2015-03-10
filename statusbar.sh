sep_line="\u2770"
glyph_wifi="\uF35C"
glyph_brightness="\uF185"
glyph_keybord="\u2328"
glyph_memory="\uF3DA"
battery_charging="\uF211"
battery_full="\uF213"
battery_medium="\uF214"
battery_low="\uF215"
volume_high="\uF028"
volume_medium="\uF027"
volume_muted="\uF026"

print_mem_free() {
  mem_free="$(free -m | awk 'NR==2 {print $7}')"
  echo -e "\x04$sep_line  $glyph_memory  ${mem_free}M "
}

print_wifi_status() {
  if [ "$(ip link | awk '/wlp1s0/{print $9}')" == "UP" ]; then
    ssid=$(iwgetid -r)
    if [ -n "$ssid" ]; then
      state=$ssid
    else
      state="not connected"
    fi
  else
    state="off"
  fi
    echo -e "$sep_line  $glyph_wifi  $state "
} 

print_volume() {
  volume="$(amixer -c 1 get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
  if [ "$volume" -ge 75 ]; then
    icon="$volume_high";
  elif [ "$volume" -ge 10 ]; then
    icon="$volume_medium";
  else
    icon="$volume_muted ";
  fi

  echo -e "$sep_line  $icon  $volume% "
}

print_datetime() {
  datetime="$(date "+%a %d %b  %H:%M")"
  echo -e "$sep_line ${datetime}"
}

print_brightness(){
  echo -e "$sep_line $glyph_brightness  $(printf '%.0f\n' $(xbacklight))% "
}
print_layout() {
  if [ "`xset -q | awk -F \" \" '/Group 2/ {print($4)}'`" = "on" ]; then 
    DWM_LAYOUT="ru"; 
  else 
    DWM_LAYOUT="en"; 
  fi; 
  echo -e " $sep_line $glyph_keybord $DWM_LAYOUT "
}

print_battery() {
  battery_level="$((`cat /sys/class/power_supply/BAT1/energy_now` * 100 / `cat /sys/class/power_supply/BAT1/energy_full`))"
  if [ "$( cat /sys/class/power_supply/ADP1/online )" -eq "1" ]; then
    icon="$battery_charging";
  elif [ "$battery_level" -ge 85 ]; then
    icon="$battery_full";
  elif [ "$battery_level" -ge 40 ]; then
    icon=$battery_medium;
  else
    icon=$battery_low;
  fi 
  echo -e "$sep_line  $icon  $battery_level%";
}

while true; do
  xsetroot -name "\
$(print_mem_free)\
$(print_wifi_status)\
$(print_volume)\
$(print_brightness)\
$(print_battery)\
$(print_layout)\
$(print_datetime)"

  sleep 1
done
  
 
