import 'package:flutter/material.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class CallAction extends StatelessWidget {
  const CallAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);

    final bg = isDark ? const Color(0xFF171A1D) : Color(0xFFF6F7F9);
    final textPrimary = isDark ? Colors.white : Color(0xFF101418);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    2,
                    173,
                    65,
                  ).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.call, color: Color.fromARGB(255, 2, 173, 65)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(icon, color: textSecondary),
            ],
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Color.fromARGB(255, 2, 173, 65),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Center(child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
