[[ -n "${_LIB_DESKTOP_LOADED:-}" ]] && return || _LIB_DESKTOP_LOADED=1

request_logout() {
  case "${XDG_CURRENT_DESKTOP,,}" in
    *gnome*)    gnome-session-quit --logout ;;
    *xfce*)     xfce4-session-logout --logout ;;
    *kde*)      qdbus6 org.kde.Shutdown /Shutdown logout 2>/dev/null \
             || qdbus org.kde.Shutdown /Shutdown logout ;;
    *cinnamon*) cinnamon-session-quit --logout ;;
    *mate*)     mate-session-save --logout ;;
    *lxqt*)	    lxqt-leave --logout ;;
    *sway*)     swaymsg exit ;;
    *i3*)       i3-msg exit ;;
    *)          loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
    esac
}
