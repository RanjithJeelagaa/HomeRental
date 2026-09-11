// ...existing code...
import 'package:flutter/material.dart';

class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  ButtonStyle _roleButtonStyle(Color color, Color hoverColor) =>
      ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? 10 : 4,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? hoverColor : color,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String displayName = 'User';
    if (routeArgs is String && routeArgs.isNotEmpty) {
      displayName = routeArgs;
    } else if (routeArgs is Map &&
        routeArgs['name'] is String &&
        (routeArgs['name'] as String).isNotEmpty) {
      displayName = routeArgs['name'] as String;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $displayName'),
        actions: [
          Tooltip(
            message: 'Logout',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Navigate to login screen and remove previous routes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome, $displayName',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add House button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      style: _roleButtonStyle(Colors.teal, Colors.tealAccent),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/addHouse'),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text('Add House')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // My Houses button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      style: _roleButtonStyle(
                        Colors.deepOrange,
                        Colors.deepOrangeAccent,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/myHouses'),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text('My Houses')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bookings button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      style: _roleButtonStyle(
                        Colors.indigo,
                        Colors.indigoAccent,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/bookings'),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text('Bookings')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ...existing code...
