#Variables {{{
#ytdl_pref="248+bestaudio/best"
##scrape 1 video link per channel instead of the default 2
#sub_link_count=1
#show_thumbnails=1
##}}}
#
##Functions {{{
#external_menu () {
#    #use rofi instead of dmenu
#    rofi -dmenu -width 1500 -p "$1"
#}

#use vlc instead of mpv
#video_player () {
#    #check if detach is enabled
#    case "$is_detach" in
      #	#disabled
      #	0) vlc "$@" ;;
      #	#enabled
      #	1) setsid -f vlc "$@" 2>&1 >/dev/null ;;
  #    esac
#}

#on_opt_parse () {
#    opt="$1"
#    arg="$2"
#    case "$opt" in
#	#-c
#	c)
#	    #when scraping subscriptions enable -l
#	    #-cSI or -cS
#	    case "$arg" in
#		S|SI) is_loop=1 ;;
#	    esac
#    esac
#}
#}}}
