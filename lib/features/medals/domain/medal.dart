enum Medal {
  gold,
  silver,
  bronze,
}

Medal parseMedal(String? raw) {
  switch (raw) {
    case 'gold':
      return Medal.gold;
    case 'silver':
      return Medal.silver;
    case 'bronze':
      return Medal.bronze;
    default:
      return Medal.bronze;
  }
}
