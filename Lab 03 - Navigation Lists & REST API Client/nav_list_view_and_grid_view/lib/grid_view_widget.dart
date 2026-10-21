import 'package:flutter/material.dart';

class GridViewWidget extends StatelessWidget {
  const GridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> Items = List.generate(
      50,
      (index) => {
        "name": "Item # ${index + 1}",
        "color": Colors.primaries[index % Colors.primaries.length]
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grid View Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Changed from 2 to 3 to make items smaller
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: Items.length,
                itemBuilder: (context, index) {
                  final item = Items[index];
                  return Card(
                    elevation: 2,
                    color: item['color'],
                    child: InkWell(
                      child: Center(child: Text("${item['name']}")),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("You Clicked on the ${item['name']}")),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}