import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import 'map_screen.dart';
import '../widgets/location_consent_dialog.dart';

/* ============================================================
   FILTERS LANDING (Age + Gender)
   After pressing "Start Icebreaker", a location consent popup
   is shown (first time only). Users must consent to share their
   location to see other users on the map.
   ============================================================ */
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _minAge = 18;
  double _maxAge = 35;

  bool male = true;
  bool female = true;
  bool nonBinary = true;

  void _start() async {
    final genders = <String>{};
    if (male) genders.add('Male');
    if (female) genders.add('Female');
    if (nonBinary) genders.add('Non-binary');

    final filters = Filters(
      minAge: _minAge.round(),
      maxAge: _maxAge.round(),
      genders: genders,
    );

    // Show location consent popup (first time only in this session)
    final consented = await showLocationConsentDialog(context);

    if (!mounted) return;

    // Navigate to map regardless – pass the consent flag
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MapScreen(
          filters: filters,
          locationSharingEnabled: consented,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ageLabel = "${_minAge.round()} - ${_maxAge.round()}";

    Widget chip2(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F4EED), Color(0xFF6A84F7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose who you want to see nearby.",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.5),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Age range",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ageLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      RangeSlider(
                        values: RangeValues(_minAge, _maxAge),
                        min: 18,
                        max: 60,
                        divisions: 42,
                        onChanged: (v) => setState(() {
                          _minAge = v.start;
                          _maxAge = v.end;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gender",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          chip2("Male", male, () => setState(() => male = !male)),
                          chip2("Female", female, () => setState(() => female = !female)),
                          chip2("Non-binary", nonBinary, () => setState(() => nonBinary = !nonBinary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tip: turn all off to show everyone.",
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      "Start Icebreaker",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}