extension Double {
  var formattedToTenth: String {
    String(format: "%.01f", self)
  }

  var formattedToHundredth: String {
    String(format: "%.02f", self)
  }
}

extension Double {
  var formattedToDMS: String {
    let isNegative = self < 0
    let degrees = Int(abs(self))
    let remainder = abs(self) - Double(degrees)
    let minutes = Int(remainder * 60)
    let seconds = (remainder - Double(minutes) / 60) * 3600
    return "\(isNegative ? "-" : "+")\(degrees)° \(minutes)' \(seconds.formattedToTenth)\""
  }
}
