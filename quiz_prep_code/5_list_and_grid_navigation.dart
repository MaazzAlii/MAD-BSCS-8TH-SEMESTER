import 'package:flutter/material.dart';

// ============================================================================
// 🎓 TEACHER'S CLASSROOM CODE: NAVIGATION, LISTVIEW.BUILDER & GRIDVIEW.BUILDER
// From teacher's whiteboard/laptop screenshots in assets/
// ============================================================================

// ============================================================================
// 🟢 [60% UNIVERSAL SKELETON - ROUTED MAIN]
// Teacher uses named routes for multi-screen navigation!
// ============================================================================
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Nav and Collection Example App",
      initialRoute: '/',
      routes: {
        '/': (context) => const ListViewWidget(),
        '/gridview': (context) => const GridViewWidget(),
      },
    );
  }
}

// ============================================================================
// 🔴 [SCREEN 1: LISTVIEW.BUILDER WITH CARD & LISTTILE]
// ============================================================================
class ListViewWidget extends StatelessWidget {
  const ListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Data generation (Teacher's exact List.generate syntax)
    final List<String> items = List.generate(
      50,
      (index) => "Item #${index + 1}",
    );

    // 🟢 Standard Scaffold & AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text("List View Example"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // 🔴 ListView.builder must be inside Expanded inside a Column!
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.add_shopping_cart),
                      title: Text(items[index]),
                      subtitle: Text("This is the description of ${items[index]}"),
                      trailing: const Icon(Icons.cancel),
                      onTap: () {
                        // Teacher's feedback message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You Clicked on the ${items[index]}"),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Navigation button to Screen 2
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/gridview');
              },
              child: const Text("Go to Grid View"),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🔴 [SCREEN 2: GRIDVIEW.BUILDER WITH SLIVERGRIDDELEGATE]
// ============================================================================
class GridViewWidget extends StatelessWidget {
  const GridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Data generation with colors
    final List<Map<String, dynamic>> items = List.generate(
      50,
      (index) => {
        "name": "Item #${index + 1}",
        "color": Colors.primaries[index % Colors.primaries.length],
      },
    );

    // 🟢 Standard Scaffold & AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grid View Example"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // 🔴 GridView.builder with SliverGridDelegate
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 2,
                    color: item['color'],
                    child: InkWell(
                      child: Center(
                        child: Text(
                          "${item['name']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You Clicked on the ${item['name']}"),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Navigation pop back
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to List View"),
            ),
          ],
        ),
      ),
    );
  }
}
