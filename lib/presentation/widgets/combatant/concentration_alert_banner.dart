import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConcentrationAlertBanner extends StatelessWidget {
  final int dc;
  final VoidCallback onKeep;
  final VoidCallback onLose;

  const ConcentrationAlertBanner({
    super.key,
    required this.dc,
    required this.onKeep,
    required this.onLose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.75),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teste de Concentração (CD $dc)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFF8A80) : Colors.red[800],
                  ),
                ),
                Text(
                  'Sofreu dano concentrando. Mantém a magia?',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: isDark ? Colors.red[100] : Colors.red[900],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor:
                  const Color(0xFF66BB6A).withValues(alpha: isDark ? 0.25 : 0.18),
              foregroundColor:
                  isDark ? const Color(0xFFA5D6A7) : Colors.green[800],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.6),
                ),
              ),
            ),
            onPressed: onKeep,
            icon: const Icon(Icons.check_circle_outline, size: 14),
            label: const Text(
              'Permanece',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor:
                  Colors.redAccent.withValues(alpha: isDark ? 0.28 : 0.18),
              foregroundColor:
                  isDark ? const Color(0xFFFF8A80) : Colors.red[800],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.65),
                ),
              ),
            ),
            onPressed: onLose,
            icon: const Icon(Icons.cancel_outlined, size: 14),
            label: const Text(
              'Perde',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
