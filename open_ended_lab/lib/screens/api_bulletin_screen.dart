import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiBulletinScreen extends StatefulWidget {
  const ApiBulletinScreen({super.key});

  @override
  State<ApiBulletinScreen> createState() => _ApiBulletinScreenState();
}

class _ApiBulletinScreenState extends State<ApiBulletinScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<SafetyBulletin>> _futureBulletins;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureBulletins = _apiService.fetchSafetyBulletins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highway & Safety Feed (API)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<List<SafetyBulletin>>(
        future: _futureBulletins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo),
                  SizedBox(height: 12),
                  Text('Fetching remote advisories from REST API...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'API Network Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.replay),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bulletins = snapshot.data ?? [];
          if (bulletins.isEmpty) {
            return const Center(child: Text('No external advisories reported.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bulletins.length,
              itemBuilder: (context, index) {
                final b = bulletins[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BULLETIN #${b.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.verified, size: 16, color: Colors.teal),
                            const SizedBox(width: 4),
                            const Text(
                              'Verified API',
                              style: TextStyle(fontSize: 11, color: Colors.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.body,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
