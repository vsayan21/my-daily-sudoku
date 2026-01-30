enum Medal {
  gold,
  silver,
  bronze,
}

String formatMedalLabel(Medal medal) {
  switch (medal) {
    case Medal.gold:
      return 'Gold';
    case Medal.silver:
      return 'Silver';
    case Medal.bronze:
      return 'Bronze';
  }
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
