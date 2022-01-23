extension Double {
  var formattedToTenth: String {
    String(format: "%.01f", self)
  }

  var formattedToHundredth: String {
    String(format: "%.02f", self)
  }
}
