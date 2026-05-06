enum DashboardMenuItem {
  settings
}

extension GridMenuPageEnumX on DashboardMenuItem {
  String get routingName {
    switch (this) {
      case DashboardMenuItem.settings:
        return "";
    }
  }

  String get title {
    switch (this) {
      case DashboardMenuItem.settings:
        return "Settings";
    }
  }

  String get iconPath {
    switch (this) {
      case DashboardMenuItem.settings:
        return "assets/settings.svg";
    }
  }
}
