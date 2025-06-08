// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class WeatherDetailPage extends StatelessWidget {
//   final Map<String, dynamic> data;
//   const WeatherDetailPage({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final isLight = Theme.of(context).brightness == Brightness.light;
//     final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
//     final subTextColor = isLight ? Colors.black54 : Colors.white54;
//     final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);
//     final List<BoxShadow> cardShadow =
//         isLight
//             ? [
//               BoxShadow(
//                 color: Color.fromRGBO(0, 0, 0, 0.04),
//                 blurRadius: 16,
//                 offset: const Offset(0, 4),
//               ),
//             ]
//             : const [];

//     final current = data['weather']['cuaca_saat_ini'] ?? {};
//     final hariIni = (data['weather']['hari_ini'] ?? []);
//     final location = data['location']?['name'] ?? 'Lokasi';

//     String formatTime(String? t) {
//       if (t == null) return '-';
//       final dt = DateTime.tryParse(t);
//       return dt != null ? DateFormat.Hm().format(dt) : '-';
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(location, style: TextStyle(color: textColor)),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: cardColor,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: cardShadow,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: List.generate(hariIni.length.clamp(0, 5), (i) {
//                 final item = hariIni[i];
//                 final day = DateFormat.E(
//                   'id_ID',
//                 ).format(DateTime.parse(item['waktu']));
//                 final temp = "${(item['suhu'] ?? 0).round()}°";
//                 return _WeatherDay(
//                   icon: Icons.cloud,
//                   day: day.toUpperCase(),
//                   temp: temp,
//                   isLight: isLight,
//                 );
//               }),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: cardColor,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: cardShadow,
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   "${(current['suhu'] ?? 0).round()}°",
//                   style: TextStyle(
//                     color: textColor,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 60,
//                   child: CustomPaint(
//                     painter: _TempLinePainter(isLight: isLight),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("12:00", style: TextStyle(color: subTextColor)),
//                     Text("13:00", style: TextStyle(color: subTextColor)),
//                     Text("14:00", style: TextStyle(color: subTextColor)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               _InfoCard(
//                 title: "UV Index",
//                 value: "${current['indeks_uv'] ?? '-'}",
//                 subtitle: "",
//                 color: Colors.green,
//                 isLight: isLight,
//               ),
//               const SizedBox(width: 12),
//               _InfoCard(
//                 title: "Terasa Seperti",
//                 value: "${(current['terasa_seperti'] ?? 0).round()}°C",
//                 subtitle: "",
//                 color: Colors.blue,
//                 isLight: isLight,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               _InfoCard(
//                 title: "Matahari",
//                 value:
//                     "${formatTime(current['matahari_terbit'])} - ${formatTime(current['matahari_terbenam'])}",
//                 subtitle: "Terbit - Terbenam",
//                 color: Colors.amber,
//                 isLight: isLight,
//               ),
//               const SizedBox(width: 12),
//               _InfoCard(
//                 title: "Kelembaban",
//                 value: "${(current['kelembapan'] ?? 0).round()}%",
//                 subtitle: "",
//                 color: Colors.cyan,
//                 isLight: isLight,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               _InfoCard(
//                 title: "Arah Angin",
//                 value: "${current['arah_angin'] ?? '-'}°",
//                 subtitle: "",
//                 color: Colors.orange,
//                 isLight: isLight,
//               ),
//               const SizedBox(width: 12),
//               _InfoCard(
//                 title: "Peluang Hujan",
//                 value: "${(current['peluang_hujan'] ?? 0).round()}%",
//                 subtitle: "",
//                 color: Colors.indigo,
//                 isLight: isLight,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _WeatherDay extends StatelessWidget {
//   final IconData icon;
//   final String day;
//   final String temp;
//   final bool selected;
//   final bool isLight;

//   const _WeatherDay({
//     required this.icon,
//     required this.day,
//     required this.temp,
//     this.selected = false,
//     required this.isLight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
//     final subTextColor = isLight ? Colors.black54 : Colors.white70;
//     return Column(
//       children: [
//         Text(
//           day,
//           style: TextStyle(
//             color: selected ? textColor : subTextColor,
//             fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Icon(icon, color: textColor, size: selected ? 32 : 26),
//         const SizedBox(height: 4),
//         Text(
//           temp,
//           style: TextStyle(
//             color: selected ? textColor : subTextColor,
//             fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String subtitle;
//   final Color color;
//   final bool isLight;

//   const _InfoCard({
//     required this.title,
//     required this.value,
//     required this.subtitle,
//     required this.color,
//     required this.isLight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final subTextColor = isLight ? Colors.black54 : Colors.white54;
//     final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);
//     final List<BoxShadow> cardShadow =
//         isLight
//             ? [
//               BoxShadow(
//                 color: Color.fromRGBO(0, 0, 0, 0.04),
//                 blurRadius: 16,
//                 offset: Offset(0, 4),
//               ),
//             ]
//             : const [];

//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         margin: const EdgeInsets.only(bottom: 8),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: cardShadow,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: TextStyle(color: subTextColor, fontSize: 12)),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (subtitle.isNotEmpty)
//               Text(
//                 subtitle,
//                 style: TextStyle(color: subTextColor, fontSize: 12),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TempLinePainter extends CustomPainter {
//   final bool isLight;
//   _TempLinePainter({required this.isLight});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = isLight ? const Color(0xFF232B3E) : Colors.white
//           ..strokeWidth = 2
//           ..style = PaintingStyle.stroke;

//     final path = Path();
//     path.moveTo(0, size.height * 0.7);
//     path.quadraticBezierTo(
//       size.width * 0.3,
//       size.height * 0.5,
//       size.width * 0.5,
//       size.height * 0.6,
//     );
//     path.quadraticBezierTo(
//       size.width * 0.7,
//       size.height * 0.8,
//       size.width,
//       size.height * 0.4,
//     );

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
