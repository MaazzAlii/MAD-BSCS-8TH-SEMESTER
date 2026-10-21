import 'package:flutter/material.dart';

class ListViewWidget extends StatelessWidget {
  const ListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> Items = List.generate(50, (index) => "Item # ${index + 1}");
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("List View Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Items.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.add_shopping_cart),
                      title: Text(Items[index]),
                      subtitle: Text("This is the description of ${Items[index]}"),
                      trailing: const Icon(Icons.cancel),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("You Clicked on the ${Items[index]}")),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
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