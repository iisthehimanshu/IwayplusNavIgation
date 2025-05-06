import 'package:flutter/material.dart';

class RouteOption {
final String id;
final String label;
final IconData icon;
final bool accessible;

RouteOption({
  required this.id,
  required this.label,
  required this.icon,
  required this.accessible,
});
}

class RouteSelector extends StatelessWidget {
  final Function(String) onRouteSelected;
  final String acc;
  RouteSelector({Key? key, required this.onRouteSelected, required this.acc}) : super(key: key);

  final List<RouteOption> routes = [
    RouteOption(
      id: 'Stairs',
      label: 'Stairs',
      icon: Icons.escalator,
      accessible: true,
    ),
    RouteOption(
      id: 'Lifts',
      label: 'Lift',
      icon: Icons.elevator,
      accessible: true,
    ),
    RouteOption(
      id: 'Ramps',
      label: 'Ramp',
      icon: Icons.accessible,
      accessible: true,
    ),
    RouteOption(
      id: 'Escalators',
      label: 'Escalator',
      icon: Icons.escalator_warning,
      accessible: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Route',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Route Options
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final route = routes[index];
                final isSelected = route.id == acc;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(route.id);
                  },
                  child: Container(
                      color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              route.icon,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Route Details
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  route.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Cancel Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.grey.shade50,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
