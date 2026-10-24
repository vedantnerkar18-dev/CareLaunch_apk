const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 5 Mar 2019
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';